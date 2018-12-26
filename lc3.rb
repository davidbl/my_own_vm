class LC3
  MAX_MEMORY =65_536
  REGISTERS = [
    R_R0 = 0,
    R_R1 = 1,
    R_R2 = 2,
    R_R3 = 3,
    R_R4 = 4,
    R_R5 = 5,
    R_R6 = 6,
    R_R7 = 7,
    R_PC = 8, #  program counter
    R_COND = 9,
    R_COUNT = 10
  ]

  OPERATIONS = [
    OP_BR = 0,    # branch
    OP_ADD = 1,   # add
    OP_LD = 2,    # load
    OP_ST = 3,    # store
    OP_JSR = 4,   # jump register
    OP_AND = 5,   # bitwise and
    OP_LDR = 6,   # load register
    OP_STR = 7,   # store register
    OP_RTI = 8,   # unused
    OP_NOT = 9,   # bitwise not
    OP_LDI = 10,  # load indirect
    OP_STI = 11,  # store indirect
    OP_JMP = 12,  # jump
    OP_RES = 13,  # reserved (unused)
    OP_LEA = 14,  # load effective address
    OP_TRAP = 15  # execute trap
  ]

  COND_FLAGS = [
    FL_POS = 1 << 0, # Positive
    FL_ZRO = 1 << 1, # Zero
    FL_NEG = 1 << 2, # Negative
  ]

  TRAP_CODES = [
    TRAP_GETC = 0x20,   # get character from keyboard
    TRAP_OUT = 0x21,    # output a character
    TRAP_PUTS = 0x22,   # output a word string
    TRAP_IN = 0x23,     # input a string
    TRAP_PUTSP = 0x24,  # output a byte string
    TRAP_HALT = 0x25    # halt the program
  ]

  PC_START = 0x3000

  attr_reader :registers
  def initialize(obj_file_path)
    @obj_file_path = obj_file_path
    @memory = Array.new(MAX_MEMORY)
    @registers = Array.new(REGISTERS.count)
    "loaded"
  end

  def execute
    load_file
    running = true

    registers[R_PC] = PC_START
    while running
      instruction = memory_read(registers[R_PC])
      registers[R_PC] += 1
      case instruction >> 12
      when OP_LEA
        destination_reg = (instruction >> 9) & 0x7
        pc_offset = sign_extend(instruction & 0x1ff, 9);
        registers[destination_reg] = registers[R_PC] + pc_offset;
        update_flags(destination_reg);
      when OP_TRAP
        case (instruction & 0xff)
        when TRAP_GETC
        when TRAP_OUT
        when TRAP_PUTS
          char_pointer = registers[R_R0]
          while char = memory_read(char_pointer)
            putc char
            char_pointer += 1
          end
        when TRAP_IN
        when TRAP_PUTSP
        when TRAP_HALT
          puts("HALT")
          running = false
        end
      end
    end
  end

  private

  def update_flags(register)

  end

  def sign_extend(base, bit_count)
    if ((base >> (bit_count - 1)) & 1) < 0
      base = base | 0xFFFF << bit_count
    end
    base
  end

  def read_file
    @raw ||= IO.binread(@obj_file_path)
  end

  def load_file
    contents = read_file.unpack('S>*')
    origin = contents.first
    contents.each do |instr|
      memory_write(origin, instr)
      origin += 1
    end
  end

  def memory_write(address, contents)
    @memory[address] = contents
  end

  def memory_read(address)
    @memory[address]
  end
end
