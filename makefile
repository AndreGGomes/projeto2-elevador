# Makefile para Projeto VHDL - Elevator System
# Utilizar TAB para indentação, não espaços!

# Diretórios
SRC_DIR = src
TB_DIR = $(SRC_DIR)/testbenches

# Arquivos VHDL na ordem de compilação correta
VHDL_FILES = \
	$(SRC_DIR)/utils/custom_types.vhd \
	$(SRC_DIR)/internal_controller/elevator/move_counter.vhd \
	$(SRC_DIR)/internal_controller/elevator/door.vhd \
	$(SRC_DIR)/internal_controller/elevator/simple_elevator.vhd \
	$(SRC_DIR)/internal_controller/next_floor_calculator.vhd \
	$(SRC_DIR)/internal_controller/at_destination_calculator.vhd \
	$(SRC_DIR)/internal_controller/call_manager.vhd \
	$(SRC_DIR)/internal_controller/call_analyzer.vhd \
	$(SRC_DIR)/internal_controller/intention_manager.vhd \
	$(SRC_DIR)/internal_controller/in_controller.vhd \
	$(SRC_DIR)/external_controller/score_calc.vhd \
	$(SRC_DIR)/external_controller/single_call_catcher.vhd \
	$(SRC_DIR)/external_controller/call_catcher.vhd \
	$(SRC_DIR)/external_controller/call_dispatcher.vhd \
	$(SRC_DIR)/external_controller/scheduler_pc.vhd \
	$(SRC_DIR)/external_controller/scheduler_po.vhd \
	$(SRC_DIR)/external_controller/scheduler.vhd \
	$(SRC_DIR)/top.vhd \
	$(TB_DIR)/top_tb.vhd

# Nome da entidade do testbench
TB_ENTITY = top_tb
VCD_OUTPUT = wave_system.vcd

# Alvo principal
all: compile elaborate run

# Compilar todos os arquivos
compile: $(VHDL_FILES)
	@echo "Compilando todos os arquivos VHDL..."
	@for file in $(VHDL_FILES); do \
		echo "Compilando: $$file"; \
		ghdl -a $$file || exit 1; \
	done
	@echo "Compilação concluída!"

# Elaborar o design
elaborate:
	@echo "Elaborando design..."
	ghdl -e $(TB_ENTITY)

# Executar simulação
run:
	@echo "Executando simulação..."
	ghdl -r $(TB_ENTITY) --vcd=$(VCD_OUTPUT)
	@echo "Simulação concluída! Waveform: $(VCD_OUTPUT)"

# Limpar arquivos gerados
clean:
	@echo "Limpando arquivos gerados..."
	rm -f *.cf
	rm -f $(TB_ENTITY)
	rm -f $(VCD_OUTPUT)
	@echo "Limpeza concluída!"

# Ajuda
help:
	@echo "Targets disponíveis:"
	@echo "  all       : Compilar, elaborar e executar (padrão)"
	@echo "  compile   : Compilar todos os arquivos VHDL"
	@echo "  elaborate : Elaborar o design"
	@echo "  run       : Executar simulação"
	@echo "  clean     : Remover arquivos gerados"
	@echo "  help      : Mostrar esta ajuda"

.PHONY: all compile elaborate run sim clean help