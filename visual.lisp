; Load the corresponding tutorial model
(load-act-r-model "ACT-R:visual-project;model.lisp")

; Create a variable to store the key that was pressed.
(defvar *response* nil)

; This is the function which we will have ACT-R call when
; a key is pressed in the experiment window which is signaled
; by the output-key action.

; That action provides two parameters to the function called.
; The first is the name of the model that performed the keypress
; or nil if it wasn't generated by a model, and the second
; is a string with the name of the key that was pressed.

(defun respond-to-key-press (model key)
  (declare (ignore model))
  ; just store the key that was pressed in the response variable
  (setf *response* key))

; This is the function that runs the experiment for either a
; person or a model.  It has one optional parameter which if
; provided as a non-nil value will run a person.
; If it is not provided or nil is specified then it will run
; the model.

(defun visual-experiment (&optional human)
  ; Reset the ACT-R system and any models that are defined to
  ; their initial states.
  (reset)
  
  ; Create variable for the items needed to run the exeperiment:
  ;   items - a randomized list of three distinct letter strings
  ;           which is randomized using the ACT-R function permute-list
  ;   window - the ACT-R window device list returned by using the ACT-R
  ;            function open-exp-window to create a new window for 
  ;            displaying the experiment 
  ;   text1, text2, text3 - three text items that will hold the letters to be 
  ;           displayed all initialized to distinct letters
  ;   target - the lexicographically smallest string among text1, text2, and text3
  
  (let* ((items (permute-list '("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K"
                                "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V"
                                "W" "X" "Y" "Z")))
         (window (open-exp-window "Letter difference"))
         (text1 (first items))
         (text2 (second items))
         (text3 (third items))
         (target (if (string-lessp text1 text2) (if (string-lessp text1 text3) text1 text3) (if (string-lessp text2 text3) text2 text3))))
    
    ; Display the three letters in the window
    (add-text-to-exp-window window text1 :x 125 :y 75)
    (add-text-to-exp-window window text2 :x 75 :y 175)
    (add-text-to-exp-window window text3 :x 175 :y 175)
    
    ; Set the response value to nil to remove any value it may
    ; have from a previous run of the experiment.
    (setf *response* nil)
    
    ; Create a command in ACT-R that corresponds to our respond-to-key-press
    ; function so that ACT-R is able to use the function.
    (add-act-r-command "visual-key-press" 'respond-to-key-press 
                       "Assignment 2 task output-key monitor")
    
    ; Monitor the output-key action so that when an output-key happens
    ; our function is called.
    (monitor-act-r-command "output-key" "visual-key-press")
    
    ; Here is where we actually "run" the experiment.
    ; It either waits for a person to press a key or runs ACT-R
    ; for up to 10 seconds giving the model a chance to do the
    ; experiment.
    (if human 
        ; If a person is doing the task then for safety 
        ; we make sure there is a visible window that they
        ; can use to do the task, and if so, loop until the
        ; response variable is not nil calling the ACT-R
        ; process-events function to allow the system a 
        ; chance to handle any interactions.
        (if (visible-virtuals-available?)
            (while (null *response*)
              (process-events)))
      (progn
        ; If it is not a human then use install-device so that
        ; the features in the window will be seen by the model
        ; (that will also automatically provide the model with
        ; access to a virtual keyboard and mouse).  Then use
        ; the ACT-R run function to run the model for up to 10
        ; seconds in real-time mode.
        (install-device window)
        (run 10 t)))
    
    ; To avoid any issues with our function for keypresses in this
    ; experiment interfering with other experiments we should stop
    ; monitoring output-key and then remove our command.
    (remove-act-r-command-monitor "output-key" "visual-key-press")
    (remove-act-r-command "visual-key-press")
    
    ; If the response matches the target return True otherwise
    ; return False.
    (if (string-equal *response* target)
        t
      nil)))