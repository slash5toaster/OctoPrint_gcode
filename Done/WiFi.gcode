M106 S0 ; turn fan off in case it was already on
M106 S200 ; turn fan on to signify start
G28 X Y ; home X & Y to signify start
; 
;  
M550 SSID_NAME
M551 SSID_PASSWORD
; 
; 
G1 X150 Y150 F1000 ; CENTER bed to signify completion M106 S0 ; turn fan off to signify completion
M84 ; disable motors
