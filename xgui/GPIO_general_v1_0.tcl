# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DEV_W" -parent ${Page_0}


}

proc update_PARAM_VALUE.DEV_W { PARAM_VALUE.DEV_W } {
	# Procedure called to update DEV_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEV_W { PARAM_VALUE.DEV_W } {
	# Procedure called to validate DEV_W
	return true
}


proc update_MODELPARAM_VALUE.DEV_W { MODELPARAM_VALUE.DEV_W PARAM_VALUE.DEV_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEV_W}] ${MODELPARAM_VALUE.DEV_W}
}

