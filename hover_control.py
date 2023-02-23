# =============================================================================
# Hovering_ATV.py
# =============================================================================
# Elementary PID Loop to Hover a Hovering ATV
# [Objective Current]: Research Basic PID Control
# [Objective Next   ]: Cascaded PID Control
#
# [Credit           ]:
#
# 2021-07-14 WUA Department of Software Development

import time
import krpc

conn = krpc.connect(name='Hovering_ATV')               # connect to KSP

# Get Active Vessel
vessel = conn.space_center.active_vessel
print(vessel.name)

# Streams & Abbreviations
alti = conn.add_stream(getattr, vessel.flight(), 'surface_altitude')
thro = conn.add_stream(getattr, vessel.control, 'throttle')
fuel = conn.add_stream(vessel.resources.amount, 'LiquidFuel')

refFrame_self = vessel.reference_frame
refFrame_surf = vessel.surface_reference_frame

dirSurf = conn.add_stream(vessel.direction, refFrame_surf)      # Direction of the vessel in surface ref.frame

print(fuel())
print(dirSurf())

auPi = vessel.auto_pilot

# User-Desired Values
altiDes = 12.5                                                  # Altitude desired for the Vessel to stay

# PID Settings
Kp = 0.1
Ki = 0.0001
Kd = 0.021

# Pre-Flight Set Up
vessel.control.sas = True
vessel.control.rcs = True

# Activate Engines
auPi.reference_frame = refFrame_surf
auPi.target_pitch = 0
auPi.target_heading = 90
auPi.engage()

print('Take Off!')
time.sleep(5)
vessel.control.activate_next_stage()

# Main Loop: PID                                # Initiate PID loop
t0 = time.time()
t_prev = t0
err_prev = altiDes - alti()
i_term = 0

time.sleep(0.001)

while fuel() > 0.1:
    auPi.target_direction = (0, dirSurf()[1], dirSurf()[2])         # somehow default target heading seems to be 0
                                                                    # while I do not want to set to anything
    delta_t = time.time() - t_prev

    err = altiDes - alti()

    p_term = Kp * (err)
    i_term = Ki * (err * delta_t) + i_term
    d_term = Kd * (err - err_prev) / delta_t

    throttle = p_term + i_term + d_term
    vessel.control.throttle = throttle
    vessel.control.throttle = max(0, min(throttle, 1))              # Ensure throttle to lie between [0, 1]

    err_prev = altiDes - alti()
    t_prev = time.time()

    time.sleep(0.001)                                               # To reduce computational burden

# =============================================================================