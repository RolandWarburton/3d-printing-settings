# ================================================================================
# STEP ONE
#
# file: printer.cfg
#
# Ensure you have these macros set up int your printers configuration file
# which can be accessed via the web interface (fluidd).
#
# For my qidi printer M141 already existed, so insert the M191 macro just below it.
# ================================================================================

```gcode
[gcode_macro M141]
gcode:
      SET_HEATER_TEMPERATURE HEATER=hot TARGET={params.S}

[gcode_macro M191]
gcode:
    {% set s = params.S|float %}
    {% if s < 25 %}
        # Do not wait for temperature to get below max room temperature
        SET_HEATER_TEMPERATURE HEATER=hot TARGET={s}
        M117 Chamber heating too low to wait
    {% else %}
        SET_HEATER_TEMPERATURE HEATER=hot TARGET={s}
        TEMPERATURE_WAIT SENSOR="heater_generic hot" MINIMUM={s-1} MAXIMUM={s+1}
        M117 Chamber at target temperature
    {% endif %}
```

# ================================================================================
# STEP TWO
#
# Inside the slicer software
#
# Within the slicer software, call this macro as part of the pre-print procedure.
# For qidislicer and likely other prusa slicer derivatives this can be found under
# > Printer Settings > Start G-code.
# ================================================================================


```gcode
PRINT_START
G28
M141 S0
G0 Z50 F600
M190 S[first_layer_bed_temperature]
;
; vvv ADD THIS LINE vvv
M191 S[volume_temperature]
; ^^^ ADD THIS LINE ^^^
;
G28 Z
G29; mesh bed leveling ,comment this code to close it
G0 X0 Y0 Z50 F6000
M109 S[first_layer_temperature]
M106 P3 S255
M83
G4 P3000
G0 X{max((min(print_bed_max[0], first_layer_print_min[0] + 80) - 85),0)} Y{max((min(print_bed_max[1], first_layer_print_min[1] + 80) - 85),0)} Z5 F6000
G0 Z[first_layer_height] F600
G1 E3 F1800
G1 X{(min(print_bed_max[0], first_layer_print_min[0] + 80))} E{85 * 0.5 * first_layer_height * nozzle_diameter[0]} F3000
G1 Y{max((min(print_bed_max[1], first_layer_print_min[1] + 80) - 85),0) + 2} E{2 * 0.5 * first_layer_height * nozzle_diameter[0]} F3000
G1 X{max((min(print_bed_max[0], first_layer_print_min[0] + 80) - 85),0)} E{85 * 0.5 * first_layer_height * nozzle_diameter[0]} F3000
G1 Y{max((min(print_bed_max[1], first_layer_print_min[1] + 80) - 85),0) + 85} E{83 * 0.5 * first_layer_height * nozzle_diameter[0]} F3000
G1 X{max((min(print_bed_max[0], first_layer_print_min[0] + 80) - 85),0) + 2} E{2 * 0.5 * first_layer_height * nozzle_diameter[0]} F3000
G1 Y{max((min(print_bed_max[1], first_layer_print_min[1] + 80) - 85),0) + 3} E{82 * 0.5 * first_layer_height * nozzle_diameter[0]} F3000
G1 X{max((min(print_bed_max[0], first_layer_print_min[0] + 80) - 85),0) + 12} E{-10 * 0.5 * first_layer_height * nozzle_diameter[0]} F3000
G1 E{10 * 0.5 * first_layer_height * nozzle_diameter[0]} F3000
```
