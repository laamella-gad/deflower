package com.laamella.deflower;

import com.laamella.vicevcf.C64MemModule;
import com.laamella.vicevcf.CiaModule;
import com.laamella.vicevcf.MainCpuModule;
import com.laamella.vicevcf.Module;
import com.laamella.vicevcf.UnhandledModule;
import com.laamella.vicevcf.VicIIModule;
import com.laamella.vicevcf.ViceVcfFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.StringJoiner;

import static java.lang.String.format;

/**
 * Starts a disassembly: makes a {@code .flo} skeleton for a {@code .vsf}
 * or {@code .prg} file (issue 0072), with what is of interest for
 * disassembling it. The facts come as
 * comments, then a {@code deflower} line, the code entries found, the
 * memory that still holds VICE's power-on pattern or only zeroes, and the
 * includes that match the banking.
 */
class Initializer {
    // The KERNAL vectors at $0314-$0333, in order, and their defaults.
    private static final String[] VECTOR_NAMES = {"irq", "brk", "nmi", "open", "close", "chkin", "chkout", "clrchn",
            "chrin", "chrout", "stop", "getin", "clall", "user", "load", "save"};
    private static final int[] VECTOR_DEFAULTS = {0xea31, 0xfe66, 0xfe47, 0xf34a, 0xf291, 0xf20e, 0xf250, 0xf333,
            0xf157, 0xf1ca, 0xf6ed, 0xf13e, 0xf32f, 0xfe66, 0xf4a5, 0xf5ed};
    // CHRGET as the KERNAL copies it to $73; the bytes at $7a/$7b are its text pointer.
    private static final int CHRGET = 0x73;
    private static final int[] CHRGET_DEFAULT = {0xe6, 0x7a, 0xd0, 0x02, 0xe6, 0x7b, 0xad, -1, -1, 0xc9, 0x3a, 0xb0,
            0x0a, 0xc9, 0x20, 0xf0, 0xef, 0x38, 0xe9, 0x30, 0x38, 0xe9, 0xd0, 0x60};
    private static final String[] VIC_MODES = {"text", "multicolor text", "bitmap", "multicolor bitmap",
            "extended color text", "invalid", "invalid", "invalid"};
    // The power-on pattern is only recognised in runs at least this long.
    private static final int MIN_POWER_ON_RUN = 64;
    // Zeroes inside a power-on run are a range of their own from this long on,
    // longer than any period of the pattern.
    private static final int MIN_ZERO_RUN = 256;
    // What is left of a run beside the zeroes in it is a range from this long on.
    private static final int MIN_RANGE = 16;
    // A power-on run holds at least this share (1/n) of both $00 and $ff.
    private static final int MIN_SHARE = 8;

    private final List<String> lines = new ArrayList<>();
    private final Map<Integer, String> codeEntries = new LinkedHashMap<>();
    private final List<String> rangeLines = new ArrayList<>();
    // The ranges in rangeLines that hold the power-on pattern or zeroes, as {start, end}.
    private final List<int[]> patternRanges = new ArrayList<>();
    private int[] memory;
    private boolean basic = true;
    private boolean kernal = true;
    private boolean io = true;
    private boolean characterRom;

    /**
     * The skeleton for this file, one line per element.
     */
    /**
     * Writes the skeleton as {@code <name>.flo} next to the file, unless
     * that exists. Returns false when it does.
     */
    boolean write(Path file) throws IOException {
        Path flowerFile = file.resolveSibling(file.getFileName().toString().replaceFirst("\\.[^.]*$", "") + ".flo");
        if (Files.exists(flowerFile)) {
            System.err.println(flowerFile + " already exists, not overwriting it.");
            return false;
        }
        System.out.println("Writing " + flowerFile);
        Files.write(flowerFile, skeleton(file));
        return true;
    }

    List<String> skeleton(Path file) throws IOException {
        String name = file.getFileName().toString();
        if (name.toLowerCase().endsWith(".prg")) {
            readProgram(file, name);
        } else {
            readSnapshot(file, name);
        }
        lines.add("deflower " + name);
        codeEntries.forEach((address, label) -> lines.add(format("$%04x code %s", address, label)));
        lines.addAll(rangeLines);
        if (basic && kernal && io) {
            lines.add("include c64.flo");
        } else {
            lines.add("include c64_zeropage.flo");
            lines.add("include c64_system.flo");
            if (basic) {
                lines.add("include c64_basic.flo");
            }
            if (io) {
                lines.add("include c64_io.flo");
            }
            if (kernal) {
                lines.add("include c64_kernal.flo");
            }
        }
        return lines;
    }

    private void readProgram(Path file, String name) throws IOException {
        memory = MemoryImage.fromPrg(file);
        byte[] prg = Files.readAllBytes(file);
        int load = MemoryImage.loadAddress(prg);
        int end = load + prg.length - 2;
        lines.add(format("; %s: loads at $%04x-$%04x", name, load, end));
        if (end > 0x10000) {
            lines.add("; the load runs past $ffff");
        }
        int[] stub = basicStub(load);
        if (stub != null) {
            lines.add(format("; BASIC stub: SYS %d", stub[1]));
            rangeLines.add(format("$%04x-$%04x byte basic_stub", load, stub[0]));
            codeEntries.put(stub[1], "start");
        }
    }

    private void readSnapshot(Path file, String name) {
        ViceVcfFile vcfFile = ViceSnapshotReader.readFile(file);
        C64MemModule c64Memory = ViceSnapshotReader.memory(vcfFile);
        memory = MemoryImage.fromRam(c64Memory.ram);
        lines.add(format("; %s: VICE snapshot of a %s", name, vcfFile.header.machineName));

        Optional<MainCpuModule> cpu = vcfFile.module("MAINCPU", MainCpuModule.class);
        int port = (c64Memory.cpuData | ~c64Memory.cpuDir) & 7;
        boolean loram = (port & 1) != 0;
        boolean hiram = (port & 2) != 0;
        boolean charen = (port & 4) != 0;
        basic = loram && hiram;
        kernal = hiram;
        io = (loram || hiram) && charen;
        characterRom = (loram || hiram) && !charen;
        lines.add(format("; $01 = $%02x: BASIC %s, KERNAL %s, %s", c64Memory.cpuData, basic ? "in" : "out",
                kernal ? "in" : "out", io ? "I/O in" : characterRom ? "character ROM in" : "I/O out"));
        powerOnPattern();

        if (cpu.isPresent()) {
            MainCpuModule c = cpu.get();
            lines.add(format("; CPU: PC $%04x A $%02x X $%02x Y $%02x SP $%02x P $%02x", c.pc, c.a, c.x, c.y, c.sp, c.status));
            if (isRam(c.pc)) {
                codeEntry(c.pc, "snapshot_pc");
            } else {
                lines.add("; the PC is in ROM");
            }
            stack(c.sp);
        } else {
            lines.add("; CPU state unknown: " + unread(vcfFile, "MAINCPU") + " isn't read");
        }

        vectors();
        video(vcfFile);
        interrupts(vcfFile, cpu);
        basicProgram();
        chrget();
    }

    private void stack(int sp) {
        if (sp == 0xff) {
            lines.add("; the stack is empty");
            return;
        }
        StringJoiner bytes = new StringJoiner(" ");
        for (int address = 0x100 + sp + 1; address < Math.min(0x200, 0x100 + sp + 17); address++) {
            bytes.add(format("%02x", memory[address]));
        }
        lines.add(format("; stack $%04x-$0200: %s%s", 0x100 + sp + 1, bytes, sp < 0xef ? " ..." : ""));
        if (sp <= 0xfd) {
            lines.add(format("; top of stack as a jsr return address: $%04x", (word(0x100 + sp + 1) + 1) & 0xffff));
        }
        if (sp <= 0xfc) {
            lines.add(format("; top of stack as an interrupt's return address: $%04x", word(0x100 + sp + 2)));
        }
    }

    private void vectors() {
        StringJoiner changed = new StringJoiner(", ");
        for (int i = 0; i < VECTOR_NAMES.length; i++) {
            int vector = 0x314 + 2 * i;
            int target = word(vector);
            if (i < 3) {
                lines.add(format("; %s $%04x -> $%04x (%s)", VECTOR_NAMES[i].toUpperCase(), vector, target, where(target)));
            } else if (target != VECTOR_DEFAULTS[i]) {
                changed.add(format("%s $%04x -> $%04x (%s)", VECTOR_NAMES[i].toUpperCase(), vector, target, where(target)));
            }
            if (i < 3 || target != VECTOR_DEFAULTS[i]) {
                codeEntry(target, i < 3 ? VECTOR_NAMES[i] : VECTOR_NAMES[i] + "_handler");
            }
        }
        if (changed.length() > 0) {
            lines.add("; changed KERNAL vectors: " + changed);
        }
        if (!kernal) {
            String[] names = {"NMI", "reset", "IRQ"};
            String[] labels = {"hardware_nmi", "reset", "hardware_irq"};
            StringJoiner hardware = new StringJoiner(", ");
            for (int i = 0; i < 3; i++) {
                int target = word(0xfffa + 2 * i);
                hardware.add(format("%s $%04x (%s)", names[i], target, where(target)));
                codeEntry(target, labels[i]);
            }
            lines.add("; hardware vectors in RAM at $fffa: " + hardware);
        }
    }

    private void video(ViceVcfFile vcfFile) {
        Optional<VicIIModule> vic = vcfFile.module("VIC-II", VicIIModule.class);
        Optional<CiaModule> cia2 = vcfFile.module("CIA2", CiaModule.class);
        if (vic.isEmpty() || cia2.isEmpty()) {
            lines.add("; video unknown: " + unread(vcfFile, "VIC-II", "CIA2") + " isn't read");
            return;
        }
        int[] r = vic.get().registers;
        int bankNumber = 3 - ((cia2.get().portA | ~cia2.get().directionA) & 3);
        int bank = bankNumber * 0x4000;
        int mode = (r[0x11] >> 4 & 2) | (r[0x16] >> 4 & 1) | (r[0x11] >> 4 & 4);
        int screen = bank + (r[0x18] >> 4) * 0x400;
        StringBuilder line = new StringBuilder(format("; VIC bank %d ($%04x-$%04x), %s, screen $%04x", bankNumber, bank,
                bank + 0x3fff, VIC_MODES[mode], screen));
        if ((r[0x11] & 0x20) != 0) {
            line.append(format(", bitmap $%04x", bank + (r[0x18] & 8) * 0x400));
        } else {
            int charset = (r[0x18] & 0xe) * 0x400;
            boolean rom = (bankNumber & 1) == 0 && (charset == 0x1000 || charset == 0x1800);
            line.append(format(", charset $%04x%s", bank + charset, rom ? " (ROM)" : ""));
        }
        if ((r[0x11] & 0x10) == 0) {
            line.append(", display off");
        }
        lines.add(line.toString());
        if (r[0x15] != 0) {
            StringJoiner sprites = new StringJoiner(", ");
            for (int i = 0; i < 8; i++) {
                if ((r[0x15] & 1 << i) != 0) {
                    sprites.add(format("%d $%04x", i, bank + memory[screen + 0x3f8 + i] * 0x40));
                }
            }
            lines.add(format("; sprites on, pointers at $%04x: %s", screen + 0x3f8, sprites));
        }
    }

    private void interrupts(ViceVcfFile vcfFile, Optional<MainCpuModule> cpu) {
        StringJoiner sources = new StringJoiner(", ");
        Optional<VicIIModule> vic = vcfFile.module("VIC-II", VicIIModule.class);
        if (vic.isPresent()) {
            int[] r = vic.get().registers;
            String[] vicSources = {format("raster at line $%03x", r[0x12] | (r[0x11] & 0x80) << 1),
                    "sprite-background collision", "sprite-sprite collision", "light pen"};
            for (int i = 0; i < vicSources.length; i++) {
                if ((r[0x1a] & 1 << i) != 0) {
                    sources.add("VIC " + vicSources[i]);
                }
            }
        }
        String[] ciaSources = {"timer A", "timer B", "TOD alarm", "serial port", "FLAG line"};
        for (String ciaName : List.of("CIA1", "CIA2")) {
            Optional<CiaModule> cia = vcfFile.module(ciaName, CiaModule.class);
            for (int i = 0; cia.isPresent() && i < ciaSources.length; i++) {
                if ((cia.get().interruptMask & 1 << i) != 0) {
                    sources.add(format("%s %s (%s)", ciaName, ciaSources[i], ciaName.equals("CIA1") ? "IRQ" : "NMI"));
                }
            }
        }
        String masked = cpu.isPresent() && (cpu.get().status & 4) != 0 ? ", IRQs masked by the I flag" : "";
        String unknown = unread(vcfFile, "VIC-II", "CIA1", "CIA2");
        lines.add("; interrupt sources: " + (sources.length() == 0 ? "none" : sources) + masked
                + (unknown.isEmpty() ? "" : ", unknown for " + unknown));
    }

    /**
     * The modules of these that no handler read, with their versions, like
     * "VIC-II 1.1".
     */
    private static String unread(ViceVcfFile vcfFile, String... moduleTypes) {
        StringJoiner unread = new StringJoiner(", ");
        for (Module module : vcfFile.modules) {
            if (module instanceof UnhandledModule && List.of(moduleTypes).contains(module.moduleType)) {
                unread.add(module.moduleType + " " + module.version);
            }
        }
        return unread.toString();
    }

    private void basicProgram() {
        int start = word(0x2b);
        int end = word(0x2d);
        StringBuilder line = new StringBuilder(format("; BASIC program $%04x-$%04x", start, end));
        int[] stub = basicStub(start);
        if (stub != null) {
            line.append(format(", SYS %d ($%04x)", stub[1], stub[1]));
        }
        lines.add(line.toString());
    }

    /**
     * The end of the BASIC program at `start` and the address its first
     * line SYSes to, or null when it has no such line.
     */
    private int[] basicStub(int start) {
        int line = start;
        int sys = -1;
        for (int lineCount = 0; lineCount < 100; lineCount++) {
            int link = word(line);
            if (link < 0) {
                return null;
            }
            if (link == 0) {
                return sys < 0 ? null : new int[]{line + 2, sys};
            }
            if (link <= line) {
                return null;
            }
            if (lineCount == 0) {
                sys = sysAddress(line + 4, link);
                if (sys < 0) {
                    return null;
                }
            }
            line = link;
        }
        return null;
    }

    /**
     * The number after the first SYS token between these addresses, or -1.
     */
    private int sysAddress(int from, int to) {
        for (int address = from; address < to && address < 0x10000; address++) {
            if (memory[address] == 0x9e) {
                int number = -1;
                for (address++; address < to && address < 0x10000; address++) {
                    int c = memory[address];
                    if (c >= '0' && c <= '9') {
                        number = (number < 0 ? 0 : number * 10) + c - '0';
                    } else if (c != ' ' && c != '(' || number >= 0) {
                        break;
                    }
                }
                return number >= 0 && number < 0x10000 ? number : -1;
            }
        }
        return -1;
    }

    private void chrget() {
        boolean patched = false;
        for (int i = 0; i < CHRGET_DEFAULT.length; i++) {
            if (CHRGET_DEFAULT[i] >= 0 && memory[CHRGET + i] != CHRGET_DEFAULT[i]) {
                patched = true;
            }
        }
        if (!patched) {
            return;
        }
        if (memory[CHRGET] == 0x4c) {
            int target = word(CHRGET + 1);
            lines.add(format("; CHRGET at $%04x patched: jmp $%04x", CHRGET, target));
            codeEntry(target, "chrget_patch");
        } else {
            lines.add(format("; CHRGET at $%04x differs from the KERNAL's", CHRGET));
        }
    }

    /**
     * Adds a line for each range that still holds VICE's power-on pattern
     * (runs of $00 and $ff, with now and then a flipped bit) or only
     * zeroes. Memory below $0400 belongs to the system and is left out,
     * like the I/O area while I/O is banked in and the hardware vectors
     * while the KERNAL is banked out. Ranges end where a visible ROM
     * starts, so they don't cover its labels.
     */
    private void powerOnPattern() {
        List<Integer> bounds = new ArrayList<>(List.of(0x400));
        if (basic) {
            bounds.addAll(List.of(0xa000, 0xc000));
        }
        if (io || characterRom) {
            bounds.addAll(List.of(0xd000, 0xe000));
        } else if (kernal) {
            bounds.add(0xe000);
        }
        if (!kernal) {
            bounds.add(0xfffa);
        }
        bounds.add(0x10000);
        for (int i = 0; i + 1 < bounds.size(); i++) {
            int from = bounds.get(i);
            if (!(from == 0xd000 && (io || characterRom)) && from != 0xfffa) {
                powerOnPattern(from, bounds.get(i + 1));
            }
        }
    }

    private void powerOnPattern(int from, int to) {
        int address = from;
        while (address < to) {
            if (!inPattern(address)) {
                address++;
                continue;
            }
            int start = address;
            int end = address;
            while (end < to && (inPattern(end) || noise(start, end))) {
                end++;
            }
            address = end + 1;
            // A byte one bit off at an edge may as well be the neighbour's
            // data (issue 0103).
            while (start < end && !exactPattern(start)) {
                start++;
            }
            while (end > start && !exactPattern(end - 1)) {
                end--;
            }
            if (end - start < MIN_POWER_ON_RUN) {
                continue;
            }
            if (balanced(start, end)) {
                splitZeroes(start, end);
            } else {
                zeroes(start, end);
            }
        }
    }

    /**
     * Whether the run holds enough of both $00 and $ff to be the power-on
     * pattern: mostly zeroes with a few other bytes is more likely sparse
     * data, like a sprite (issue 0103).
     */
    private boolean balanced(int start, int end) {
        int zeroes = 0;
        int ones = 0;
        for (int address = start; address < end; address++) {
            if (memory[address] == 0) {
                zeroes++;
            } else if (memory[address] == 0xff) {
                ones++;
            }
        }
        int least = (end - start) / MIN_SHARE;
        return zeroes >= least && ones >= least;
    }

    /**
     * Adds the runs of only zeroes in the run as unused.
     */
    private void zeroes(int start, int end) {
        int address = start;
        while (address < end) {
            if (memory[address] != 0) {
                address++;
                continue;
            }
            int zeroes = address;
            while (address < end && memory[address] == 0) {
                address++;
            }
            if (address - zeroes >= MIN_POWER_ON_RUN) {
                addRange(zeroes, address, "unused");
            }
        }
    }

    /**
     * Adds the run as untouched, apart from the long runs of zeroes in it.
     */
    private void splitZeroes(int start, int end) {
        int untouched = start;
        int address = start;
        while (address < end) {
            if (memory[address] != 0) {
                address++;
                continue;
            }
            int zeroes = address;
            while (address < end && memory[address] == 0) {
                address++;
            }
            boolean wholeRun = zeroes == start && address == end;
            if (wholeRun || address - zeroes >= MIN_ZERO_RUN) {
                addRange(untouched, zeroes, "untouched");
                addRange(zeroes, address, "unused");
                untouched = address;
            }
        }
        addRange(untouched, end, "untouched");
    }

    private void addRange(int start, int end, String kind) {
        if (end - start >= MIN_RANGE) {
            patternRanges.add(new int[]{start, end});
            rangeLines.add(format("$%04x-$%04x virtual byte %s_%04x", start, end, kind, start));
        }
    }

    /**
     * $00 or $ff, or one bit off from it next to one that is: VICE flips
     * a bit now and then, but a run of values with one bit set, like a
     * screen of spaces, isn't the pattern.
     */
    private boolean inPattern(int address) {
        if (exactPattern(address)) {
            return true;
        }
        int bits = Integer.bitCount(memory[address]);
        return (bits == 1 || bits == 7)
                && (address > 0 && exactPattern(address - 1) || address < 0xffff && exactPattern(address + 1));
    }

    /**
     * Any byte between two exact ones, in a run already long enough: VICE
     * sets a byte at random now and then, which shouldn't split a long run
     * of the pattern (issue 0103).
     */
    private boolean noise(int start, int address) {
        return address - start >= MIN_POWER_ON_RUN && address < 0xffff
                && exactPattern(address - 1) && exactPattern(address + 1);
    }

    private boolean exactPattern(int address) {
        return memory[address] == 0 || memory[address] == 0xff;
    }

    /**
     * Adds a code entry, unless the address is in ROM, the zero page, the
     * hardware vectors or memory the program never touched, like a vector
     * left pointing into RAM under the KERNAL.
     */
    private void codeEntry(int address, String label) {
        if (address >= 0x100 && address < 0xfffa && where(address).equals("RAM")) {
            codeEntries.putIfAbsent(address, label);
        }
    }

    private String where(int address) {
        if (!isRam(address)) {
            return "ROM";
        }
        for (int[] range : patternRanges) {
            if (address >= range[0] && address < range[1]) {
                return "RAM, untouched";
            }
        }
        return "RAM";
    }

    private boolean isRam(int address) {
        if (address >= 0xa000 && address < 0xc000) {
            return !basic;
        }
        if (address >= 0xd000 && address < 0xe000) {
            return !io && !characterRom;
        }
        if (address >= 0xe000) {
            return !kernal;
        }
        return true;
    }

    /**
     * The little-endian word here, or -1 when a byte of it isn't loaded.
     */
    private int word(int address) {
        if (address + 1 >= 0x10000 || memory[address] < 0 || memory[address + 1] < 0) {
            return -1;
        }
        return memory[address] | memory[address + 1] << 8;
    }
}
