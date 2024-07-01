export DESIGN_NICKNAME = sha256_naive
export DESIGN_NAME = sha256top
export PLATFORM    = nangate45

export VERILOG_FILES = $(sort $(wildcard ./designs/src/$(DESIGN_NICKNAME)/*.v))
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION = 50
export CORE_ASPECT_RATIO = 1
#export CORE_MARGIN = 2

export PLACE_DENSITY = 0.61
#export TNS_END_PERCENT        = 100
#export EQUIVALENCE_CHECK     ?=   1
