package com.laamella.deflower;

import com.laamella.mpu6502.specification.AddressingMode;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import static com.laamella.Printing.asHexWord;

/**
 * Looks through the decoded code, after the flow analysis, for self-modifying
 * code (issue 0106): an instruction whose operand another instruction writes
 * or modifies.
 */
class SelfModificationFinder {
    /**
     * Records each instruction whose operand bytes an instruction writes to,
     * with the writers, in `Subject.operandWriters`. The operand of such an
     * instruction holds whatever it held when the image was taken, so it
     * names nothing: the auto labels only it made are dropped. A branch
     * offset stays, since its target is code either way.
     */
    void find(Subject subject) {
        for (MemoryLocation location : subject.memory) {
            Area area = location.area;
            if (!(area instanceof InstructionArea) || area.address != location.address) {
                continue;
            }
            InstructionArea writer = (InstructionArea) area;
            if (!CrossReferences.changesTarget(writer.instruction)) {
                continue;
            }
            int target = CrossReferences.target(writer, subject);
            Area written = target == -1 ? null : subject.memory[target].area;
            if (written instanceof InstructionArea && written.address != target
                    && ((InstructionArea) written).instruction.addressingMode != AddressingMode.RELATIVE) {
                subject.operandWriters.computeIfAbsent(written.address, a -> new TreeSet<>()).add(writer.address);
            }
        }
        resolveSelfModNames(subject);
        Set<Integer> referenced = subject.referencedAddresses();
        for (int address : subject.operandWriters.keySet()) {
            int target = CrossReferences.target((InstructionArea) subject.memory[address].area, subject);
            Label label = target == -1 ? null : subject.memory[target].label;
            if (label != null && label.auto && !referenced.contains(target)) {
                subject.memory[target].label = null;
            }
        }
    }

    /**
     * Finds the label each selfmod line names (issue 0106), a .flo label
     * or a banked name, into `Subject.selfModLabels`. A line that isn't
     * on an instruction with an address operand, or names no such label,
     * is an error; one on an instruction no traced code writes is a
     * warning.
     */
    private void resolveSelfModNames(Subject subject) {
        Map<String, Integer> addressByName = new HashMap<>();
        for (MemoryLocation location : subject.memory) {
            if (location.banked != null) {
                addressByName.putIfAbsent(location.banked.name, location.address);
            }
            if (location.label != null && !location.label.auto) {
                addressByName.putIfAbsent(location.label.name, location.address);
            }
        }
        subject.selfModNames.forEach((address, name) -> {
            Area area = subject.memory[address].area;
            if (!(area instanceof InstructionArea) || area.address != address
                    || CrossReferences.target((InstructionArea) area, subject) == -1
                    || ((InstructionArea) area).instruction.addressingMode == AddressingMode.RELATIVE) {
                subject.errors.add(String.format("Selfmod line at %s: no instruction with an address operand there", asHexWord(address)));
                return;
            }
            Integer labelAddress = addressByName.get(name);
            if (labelAddress == null) {
                subject.errors.add(String.format("Selfmod line at %s names %s, which is no label", asHexWord(address), name));
                return;
            }
            if (!subject.operandModified(address)) {
                // Not an error: the code that writes it may not be traced yet.
                subject.warn(address, "selfmod line, but no traced instruction writes the operand");
            }
            subject.selfModLabels.put(address, labelAddress);
            Label banked = subject.memory[labelAddress].banked;
            if (banked != null && banked.name.equals(name)) {
                subject.usedBanked.add(labelAddress);
            }
        });
    }
}
