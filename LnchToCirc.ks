//LnchToCirc.ks
CLEARSCREEN.

// ------------------------------------------------------
// Radius of Celestial Body to Orbit
SET R  TO KERBIN:RADIUS.         // Radius of Kerbin
// Gravitational Parameter of Celestial Body to Orbit
SET mu TO KERBIN: MU.            //     Mu of Kerbin
// -------------------------------------------------------------------------------
// Set goal apoapsis and periapsis
//SET ApoaGoal TO 300000.
SET ApoaGoal TO 2863330.

// lock variables for convenience 
LOCK alti      TO SHIP:ALTITUDE.
LOCK apoa      TO SHIP:APOAPSIS.
LOCK peri      TO SHIP:PERIAPSIS.
LOCK veloOrbit TO SHIP:VELOCITY:ORBIT:MAG.
// -------------------------------------------------------------------------------

// Lock throttle to 100% 
LOCK THROTTLE TO 1.0.
PRINT "Throttle Level: 100 [%]".

// Countdown
PRINT "Initiate Countdown:".
FROM {local count is 3.} UNTIL count = 0 STEP {SET count to count - 1.} DO {
	PRINT count.
	WAIT 1. //pause script for 1 [sec]
}
PRINT "!!! LIFT OFF !!!".

// Activate stage whenever ship thrust is 0
WHEN MAXTHRUST = 0 THEN {.
	PRINT "Stage Activated".
	STAGE.
	PRESERVE.
}

// Set heading and perform Gravity Turn
SET MYSTEER TO HEADING(90, 90).
LOCK STEERING TO MYSTEER.
SET AltiBuffer TO 2000.
UNTIL apoa > (ApoaGoal - AltiBuffer) {
	IF alti < 3000 {
		SET MYSTEER TO HEADING(90, 90).
		PRINT "Set Pitch Angle to  0 [DEG]"            AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 0)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 0)   AT(2, 18).
	
	} ELSE IF SHIP:ALTITUDE >= 3000 AND SHIP:ALTITUDE < 5000 {	
		SET MYSTEER TO HEADING(90, 80).
		PRINT "Set Pitch Angle to  80 [DEG]"           AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 4)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 4)   AT(2, 18).
	
	} ELSE IF SHIP:ALTITUDE >= 5000 AND SHIP:ALTITUDE < 7000 {	
		SET MYSTEER TO HEADING(90, 70).
		PRINT "Set Pitch Angle to  70 [DEG]"           AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 4)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 4)   AT(2, 18).
	
	} ELSE IF SHIP:ALTITUDE >= 7000 AND SHIP:ALTITUDE < 9000 {	
		SET MYSTEER TO HEADING(90, 60).
		PRINT "Set Pitch Angle to  60 [DEG]"           AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 4)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 4)   AT(2, 18).
	
	} ELSE IF SHIP:ALTITUDE >= 9000 AND SHIP:ALTITUDE < 15000 {	
		SET MYSTEER TO HEADING(90, 50).
		PRINT "Set Pitch Angle to  50 [DEG]"           AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 4)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 4)   AT(2, 18).
	
	} ELSE IF SHIP:ALTITUDE >= 15000 AND SHIP:ALTITUDE < 30000 {	
		SET MYSTEER TO HEADING(90, 40).
		PRINT "Set Pitch Angle to  40 [DEG]"           AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 4)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 4)   AT(2, 18).
	
	} ELSE IF SHIP:ALTITUDE >= 30000 AND SHIP:ALTITUDE < 45000 {	
		SET MYSTEER TO HEADING(90, 30).
		PRINT "Set Pitch Angle to  30 [DEG]"           AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 4)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 4)   AT(2, 18).
	
	} ELSE IF SHIP:ALTITUDE >= 45000 AND SHIP:ALTITUDE < 65000 {	
		SET MYSTEER TO HEADING(90, 20).
		PRINT "Set Pitch Angle to  20 [DEG]"           AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 4)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 4)   AT(2, 18).
	
	} ELSE IF SHIP:ALTITUDE >= 60000 AND SHIP:ALTITUDE < 80000 {	
		SET MYSTEER TO HEADING(90, 10).
		PRINT "Set Pitch Angle to  10 [DEG]"           AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 4)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 4)   AT(2, 18).
	
	} ELSE IF SHIP:ALTITUDE >= 80000 {
		SET MYSTEER TO HEADING(90, 0).
		PRINT "Set Pitch Angle to  0 [DEG]"            AT(2, 16).
		PRINT "CURRENT PERIAPSIS: " + ROUND(peri, 4)   AT(2, 17).
		PRINT "CURRENT APOAPSIS : " + ROUND(apoa, 4)   AT(2, 18).
	}
}.

// Fine Tune Orbit
SET STEERING TO HEADING(90, 0).
UNTIL apoa > ApoaGoal {
	LOCK THROTTLE TO 0.1.
}.

// Cut throttle when the goal apoapsis reached
PRINT "Apoapsis : " + ApoaGoal*10^(-3) + " [km] Reached, Cutting Throttle".
LOCK THROTTLE TO 0.
SET SHIP.CONTROL.PILOTMAINTHROTTLE TO 0.

// Re-Ignite Engine near the apoaosis
SET AltiBuffer TO 1.
WAIT UNTIL alti > (apoa - AltiBuffer).
PRINT "Vehicle is near the Apoapsis. Re-Ignite Engine". 

// Set Ship to Due EAST
SET STEERING TO HEADING(90, 0).

// Get Needed delta-V to Circularize
SET delV TO DelV_ELtoCR(R, mu, apoa, peri).   //함수 호출
PRINT "delV Needed: " + delV + " [m/s]".

// Calculate orbital velocities at the transfer point
SET VeloElliApo TO veloOrbit.
SET VeloCirc    TO VeloElliApo + delV.

// Set to tangential direction and
// Accelerate until circular velocity
UNTIL veloOrbit > (VeloCirc - 10) {
	LOCK THROTTLE TO 1.0.
} 
// Fine Tune
UNTIL veloOrbit > VeloCirc {
	LOCK THROTTLE TO 0.1.
}
// Report status and cut throttle
PRINT "Circular Orbit of r ~: " + apoa*10^(-3) + " [km] Formed" AT(2, 19).
LOCK THROTTLE TO 0.
SET SHIP.CONTROL.PILOTMAINTHROTTLE TO 0.

// --------------------- FUNCTIONS --------------------- //
FUNCTION DelV_ELtoCR {
    PARAMETER R.
    PARAMETER mu.
    PARAMETER apoa.
    PARAMETER peri.

    SET rA TO (apoa + R).           //  Apoapsis 
    SET rP TO (peri + R).           // Periapsis
    SET r  TO rA.

    // Calculate deltaV
    RETURN (mu/r)^(1/2) - (2*mu*(1/r - 1/(rP + R)))^(1/2).
}.