;-------------- get patient details -----------------------------
(defrule get_name
	(initial-fact)
	=>
	(printout t "------------ Island Hospital's Medical Diagnosis System ---------------" crlf)
	(printout t crlf)
	(printout t "Enter patient's name: ")
	(bind ?name (read))
	(assert (name ?name))
)

(defrule get_height
	(name ?)
	=>
	(printout t "Enter patient's height(m): ")
	(bind ?height (read))
	(assert (height ?height))
)

(defrule get_weight
	(name ?)
	(height ?)
	=>
	(printout t "Enter patient's weight(kg): ")
	(bind ?weight (read))
	(assert (weight ?weight))
)

; ---------------calculate bmi and determine the standard -----------------------------
(defrule get_bmi
	(name ?name)
	(height ?height)
	(weight ?weight)
	=>
	(bind ?bmi (/ ?weight (** ?height 2)))
	(round ?bmi)
	(printout t "Patient's BMI is " ?bmi crlf)
	(assert (bmi ?bmi))
)


(defrule underweight
	(bmi ?bmi)
	(name $?name)
	(test (< ?bmi 18.5))
	=>
	(printout t "Patient " ?name " is underweight." crlf)
	(bind ?bmi_status underweight)
	(assert (bmi_status ?bmi_status))
)

(defrule normal
	(bmi ?bmi)
	(name ?name)
	(and
		(test (>= ?bmi 18.5))
		(test (<= ?bmi 24.9))
	)
	=>
	(printout t "Patient " ?name " has a healthy weight." crlf)
	(bind ?bmi_status normal_weight)
	(assert (bmi_status ?bmi_status))
)

(defrule overweight
	(bmi ?bmi)
	(name ?name)
	(and
		(test (>= ?bmi 25))
		(test (<= ?bmi 29.9))
	)
	=>
	(printout t "Patient " ?name " is overweight." crlf)
	(bind ?bmi_status overweight)
	(assert (bmi_status ?bmi_status))
)

(defrule obese
	(bmi ?bmi)
	(name ?name)
	(and
		(test (>= ?bmi 30))
		(test (<= ?bmi 34.9))
	)
	=>
	(printout t "Patient " ?name " is obese." crlf)
	(bind ?bmi_status obese)
	(assert (bmi_status ?bmi_status))
)

(defrule extremely_obese
	(bmi ?bmi)
	(name ?name)
	(test (>= ?bmi 35))
	=>
	(printout t "Patient " ?name " is extremely obese." crlf)
	(bind ?bmi_status extremely_obese)
	(assert (bmi_status ?bmi_status))
)

;-------------------------- if patient is underweight or extremly obese, schedule for doctor's appointment and end program----------


(defrule see_doc
	?fact_bmistatus <- (bmi_status ?bmi_status)
	?fact_name <- (name ?name)
	(or
		(bmi_status underweight)
		(bmi_status extremely_obese)
	)
	=>
	(printout t "Scheduling patient " ?name " for doctor's appointment." crlf)
	(printout t crlf)
	
	; ask if user would like to continue
	(printout t "Would you like to continue to diagnose another patient (y/n) :  ")
	(assert (continue (lowcase(read))))
	
)

; continue 
(defrule next1
	?cont <- (continue y)
	?fact_bmistatus <- (bmi_status ?bmi_status)
	?fact_name <- (name ?name)
	?fact_bmi <- (bmi ?bmi)
	?fact_weight <- (weight ?weight)
	?fact_height <- (height ?height)
	=>
	(refresh get_name)
	(retract ?cont)
	;;;; retract facts so easier as no need to reset while running the program again
	(retract ?fact_name)
	(retract ?fact_bmistatus)
	(retract ?fact_bmi)
	(retract ?fact_weight)
	(retract ?fact_height)
	
)

; end program and retract facts
(defrule stop1
	?cont <- (continue n)
	?fact_bmistatus <- (bmi_status ?bmi_status)
	?fact_name <- (name ?name)
	?fact_bmi <- (bmi ?bmi)
	?fact_weight <- (weight ?weight)
	?fact_height <- (height ?height)
	=>
	;;;; retract facts to stop the program	
	
	(retract ?fact_name)
	(retract ?fact_bmistatus)
	(retract ?fact_bmi)
	(retract ?fact_weight)
	(retract ?fact_height)	
	(retract ?cont)
)

; ------------------------------ if not underweight or extremely obese, proceed to diagnosis------------------------------------

; prompt user to enter if he is a smoker or not
(defrule smoker
	(bmi_status ?bmi_status)
	(name ?name)
	(and
		(not(bmi_status underweight))
		(not(bmi_status extremely_obese))
	)
	=>
	(printout t crlf)
	(printout t "*************** Entering Heart Diagnosis Section *****************" crlf)
	(printout t crlf)
	(printout t "Is the patient a smoker? (yes/no) : ")
	(bind ?smoker (read))
	(assert (smoker ?smoker))
)


;;;;;; output the diagnosis based on bmi status & smoker/non-smoker

(defrule normal_smoker
	(smoker ?smoker)
	(bmi_status ?bmi_status)
	(name ?name)
	(bmi ?bmi)
	(weight ?weight)
	(height ?height)
	(and
		(smoker yes)
		(bmi_status normal_weight)
	)
	=>
	;;; print the diagnosis report
	(printout t " ------- Diagnosis Report for " ?name " -------------------" crlf)
	(printout t "   1. BMI : " ?bmi "                                       " crlf)
	(printout t "   2. BMI standard: " ?bmi_status "                        " crlf)
	(printout t "   3. Weight : " ?weight " kg                              " crlf)
	(printout t "   4. Height : " ?height " m                               " crlf)
	(printout t "   5. Smoker : " ?smoker "                                 " crlf)
	(printout t "   6. Health risks : Heart Diseases, Stroke, Lung Diseases " crlf)
	(printout t " ----------------------------------------------------------" crlf)
	(printout t crlf)
	(printout t "Would you like to continue to diagnose another patient :  (y/n)")
	(assert (continue2 (lowcase(read))))
	
)

(defrule normal_nonsmoker
	(smoker ?smoker)
	(bmi_status ?bmi_status)
	(name ?name)
	(bmi ?bmi)
	(weight ?weight)
	(height ?height)
	(and
		(smoker no)
		(bmi_status normal_weight)
	)
	=>
	(printout t " ------- Diagnosis Report for " ?name " --------" crlf)
	(printout t "   1. BMI : " ?bmi "                            " crlf)
	(printout t "   2. BMI standard: " ?bmi_status "             " crlf)
	(printout t "   3. Weight : " ?weight " kg                   " crlf)
	(printout t "   4. Height : " ?height " m                    " crlf)
	(printout t "   5. Smoker : " ?smoker "                      " crlf)
	(printout t "   6. Health risks : None                       " crlf)
	(printout t " -----------------------------------------------" crlf)
	(printout t crlf)
	(printout t "Would you like to continue to diagnose another patient (y/n) :  ")
	(assert (continue2 (lowcase(read))))
)

(defrule overweight_smoker
	(smoker ?smoker)
	(bmi_status ?bmi_status)
	(name ?name)
	(bmi ?bmi)
	(weight ?weight)
	(height ?height)
	(and
		(smoker yes)
		(bmi_status overweight)
	)
	=>
	(printout t " ---------------Diagnosis Report for " ?name " -----------------------------------" crlf)
	(printout t "   1. BMI : " ?bmi "                                                              " crlf)
	(printout t "   2. BMI standard: " ?bmi_status "                                               " crlf)
	(printout t "   3. Weight : " ?weight " kg                                                     " crlf)
	(printout t "   4. Height : " ?height " m                                                      " crlf)
	(printout t "   5. Smoker : " ?smoker "                                                        " crlf)
	(printout t "   6. Health risks : Heart Diseases, Hypertension, Diabetes, Lung Diseases, Stroke" crlf)
	(printout t " ---------------------------------------------------------------------------------" crlf)
	(printout t crlf)
	(printout t "Would you like to continue to diagnose another patient (y/n): ")
	(assert (continue2 (lowcase(read))))
)

(defrule overweight_nonsmoker
	(smoker ?smoker)
	(bmi_status ?bmi_status)
	(name ?name)
	(bmi ?bmi)
	(weight ?weight)
	(height ?height)
	(and
		(smoker no)
		(bmi_status overweight)
	)
	=>
	(printout t " ------- Diagnosis Report for " ?name " ----------" crlf)
	(printout t "   1. BMI : " ?bmi "                             " crlf)
	(printout t "   2. BMI standard: " ?bmi_status "              " crlf)
	(printout t "   3. Weight : " ?weight " kg                    " crlf)
	(printout t "   4. Height : " ?height " m                     " crlf)
	(printout t "   5. Smoker : " ?smoker "                       " crlf)
	(printout t "   6. Health risks : Diabetes, Hypertension      " crlf)
	(printout t " -------------------------------------------------" crlf)
	(printout t crlf)
	(printout t "Would you like to continue to diagnose another patient (y/n) :  ")
	(assert (continue2 (lowcase(read))))	
)

(defrule obese_smoker
	(smoker ?smoker)
	(bmi_status ?bmi_status)
	(name ?name)
	(bmi ?bmi)
	(weight ?weight)
	(height ?height)
	(and
		(smoker yes)
		(bmi_status obese)
	)
	=>
	(printout t " ------- Diagnosis Report for " ?name " -------------------------------------------------------------" crlf)
	(printout t "   1. BMI : " ?bmi "                                                                                 " crlf)
	(printout t "   2. BMI standard: " ?bmi_status "                                                                  " crlf)
	(printout t "   3. Weight : " ?weight " kg                                                                        " crlf)
	(printout t "   4. Height : " ?height " m                                                                         " crlf)
	(printout t "   5. Smoker : " ?smoker "                                                                           " crlf)
	(printout t "   6. Health risks : Hypertension, Heart Diseases, Fatigue, Dyspnea, Diabetes, Lung Diseases, Stroke " crlf)
	(printout t " ----------------------------------------------------------------------------------------------------" crlf)	
	(printout t crlf)
	(printout t "Would you like to continue to diagnose another patient (y/n):  ")
	(assert (continue2(lowcase(read))))
)

(defrule obese_nonsmoker
	(smoker ?smoker)
	(bmi_status ?bmi_status)
	(name ?name)
	(bmi ?bmi)
	(weight ?weight)
	(height ?height)
	(and
		(smoker no)
		(bmi_status obese)
	)
	=>
	(printout t " ---------------------- Diagnosis Report for " ?name " --------------" crlf)
	(printout t "   1. BMI : " ?bmi "                                                 " crlf)
	(printout t "   2. BMI standard: " ?bmi_status "                                  " crlf)
	(printout t "   3. Weight : " ?weight " kg                                        " crlf)
	(printout t "   4. Height : " ?height " m                                         " crlf)
	(printout t "   5. Smoker : " ?smoker "                                           " crlf)
	(printout t "   6. Health risks : Heart Diseases, Fatigue, Diabetes, Hypertension " crlf)
	(printout t " --------------------------------------------------------------------" crlf)
	(printout t crlf)
	(printout t "Would you like to continue to diagnose another patient (y/n) :  ")
	(assert (continue2 (lowcase(read))))	
)


(defrule next2
	?cont2 <- (continue2 y)
	?fact_bmistatus <- (bmi_status ?bmi_status)
	?fact_name <- (name ?name)
	?fact_bmi <- (bmi ?bmi)
	?fact_weight <- (weight ?weight)
	?fact_height <- (height ?height)
	?fact_smoker <- (smoker ?smoker)
	=>
	(refresh get_name)
	(retract ?cont2)
	;;;; retract facts so easier as no need to reset while running the program again
	(retract ?fact_name)
	(retract ?fact_bmistatus)
	(retract ?fact_bmi)
	(retract ?fact_smoker)
	(retract ?fact_weight)
	(retract ?fact_height)
	
)

(defrule stop2
	?cont2 <- (continue2 n)
	?fact_bmistatus <- (bmi_status ?bmi_status)
	?fact_name <- (name ?name)
	?fact_bmi <- (bmi ?bmi)
	?fact_weight <- (weight ?weight)
	?fact_height <- (height ?height)
	?fact_smoker <- (smoker ?smoker)
	=>
	;;;; retract facts to stop the program	
	
	(retract ?fact_name)
	(retract ?fact_bmistatus)
	(retract ?fact_bmi)
	(retract ?fact_smoker)
	(retract ?fact_weight)
	(retract ?fact_height)	
	(retract ?cont2)
)