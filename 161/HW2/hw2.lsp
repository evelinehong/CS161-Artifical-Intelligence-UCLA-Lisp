;;;;;;;;;;;;;;
; Homework 2 ;
;;;;;;;;;;;;;;

;;;;;;;;;;;;;;
; Question 1 ;
;;;;;;;;;;;;;;

;the point of this question is that we want to take off the () from inside to ouside;
;Find the shallowest element (surrounded by least () pairs)

 (defun BFS (FRINGE)
    (cond ((null FRINGE) NIL)
          ; If car is not atom, we perform "shift left", that is, recursively switch cdr and car and call BFS until we find an atom 
          ((not (atom (car FRINGE))) (BFS (append (cdr FRINGE) (car FRINGE))))
          ; Else, we can cons car and BFS of cdr
          (T (cons (car FRINGE) (BFS (cdr FRINGE))))
    )    
)

;;;;;;;;;;;;;;
; Question 2 ;
;;;;;;;;;;;;;;


; These functions implement a depth-first solver for the homer-baby-dog-poison
; problem. In this implementation, a state is represented by a single list
; (homer baby dog poison), where each variable is T if the respective entity is
; on the west side of the river, and NIL if it is on the east side.
; Thus, the initial state for this problem is (NIL NIL NIL NIL) (everybody 
; is on the east side) and the goal state is (T T T T).

; The main entry point for this solver is the function DFS, which is called
; with (a) the state to search from and (b) the path to this state. It returns
; the complete path from the initial state to the goal state: this path is a
; list of intermediate problem states. The first element of the path is the
; initial state and the last element is the goal state. Each intermediate state
; is the state that results from applying the appropriate operator to the
; preceding state. If there is no solution, DFS returns NIL.
; To call DFS to solve the original problem, one would call 
; (DFS '(NIL NIL NIL NIL) NIL) 
; However, it should be possible to call DFS with a different initial
; state or with an initial path.

; First, we define the helper functions of DFS.

; FINAL-STATE takes a single argument S, the current state, and returns T if it
; is the goal state (T T T T) and NIL otherwise.
(defun FINAL-STATE (S)
     ;goal state
     (equal S '(T T T T)))

; NEXT-STATE returns the state that results from applying an operator to the
; current state. It takes three arguments: the current state (S), and which entity
; to move (A, equal to h for homer only, b for homer with baby, d for homer 
; with dog, and p for homer with poison). 
; It returns a list containing the state that results from that move.
; If applying this operator results in an invalid state (because the dog and baby,
; or poisoin and baby are left unsupervised on one side of the river), or when the
; action is impossible (homer is not on the same side as the entity) it returns NIL.
; NOTE that next-state returns a list containing the successor state (which is
; itself a list); the return should look something like ((NIL NIL T T)).
(defun NEXT-STATE (S A)
  ;Homer alone
  (cond ((equal A 'h) 
        ;invalid (because the dog and baby, or poisoin and baby are left unsupervised on one side of the river)
        (cond ((and (equal (first S) (second S)) (or (equal (second S) (third S)) (equal (second S) (fourth S)))) NIL)
        ;valid
              (T (list (cons (NOT (first S)) (cdr S))))))
  
  
        ;Homer with a baby
        ((equal A 'b)
        ;valid (homer and the baby are on the same side
        (cond ((equal (first S) (second S)) (list (list (NOT (first S)) (NOT (second S)) (third S) (fourth S))))
              (T NIL)))

        ;Homer with a dog
        ((equal A 'd)
        ;invalid (homer not with the dog or baby and poison will be on the same side)
        (cond ((or (NOT (equal (first S) (third S))) (equal (second S) (fourth S))) NIL)
              (T (list (list (NOT (first S)) (second S) (NOT (third S)) (fourth S)))))) 

        ;Homer with poison
        ((equal A 'p)
        ;invalid (homer not with the dog or baby and poison will be on the same side)
        (cond ((or (NOT (equal (first S) (fourth S))) (equal (second S) (third S))) NIL)
              (T (list (list (NOT (first S)) (second S) (third S) (NOT (fourth S)))))))
    
        (T NIL))
)  

; SUCC-FN returns all of the possible legal successor states to the current
; state. It takes a single argument (s), which encodes the current state, and
; returns a list of each state that can be reached by applying legal operators
; to the current state.
(defun SUCC-FN (S)
    ;We use append to take out ()
    (append (NEXT-STATE S 'h) (NEXT-STATE S 'b) (NEXT-STATE S 'd) (NEXT-STATE S 'p))
)

; ON-PATH checks whether the current state is on the stack of states visited by
; this depth-first search. It takes two arguments: the current state (S) and the
; stack of states visited by DFS (STATES). It returns T if s is a member of
; states and NIL otherwise.
(defun ON-PATH (S STATES)
  ;Current state is not on the stack of states
  (cond ((null STATES) NIL)
        ;Current state is on the stack
        (T (cond ((equal (car STATES) S) T)
                (T (ON-PATH S (cdr STATES)))))
  )
)

; MULT-DFS is a helper function for DFS. It takes two arguments: a list of
; states from the initial state to the current state (PATH), and the legal
; successor states to the last, current state in the PATH (STATES). PATH is a
; first-in first-out list of states; that is, the first element is the initial
; state for the current search and the last element is the most recent state
; explored. MULT-DFS does a depth-first search on each element of STATES in
; turn. If any of those searches reaches the final state, MULT-DFS returns the
; complete path from the initial state to the goal state. Otherwise, it returns
; NIL.
(defun MULT-DFS(STATES PATH)
   (cond ((null STATES) NIL)
         ;reaches goal states
         ((FINAL-STATE (car STATES))
              (append PATH (list (car STATES))))
         ;check if states contain a valid one, recursively find a valid one
         ((ON-PATH (car STATES) PATH)
              (MULT-DFS (cdr STATES) PATH))
         ;find a valid one, do MULT-DFS after appending current state. Always execute the first input of or
         (T (or (MULT-DFS (SUCC-FN (car STATES)) (append PATH (list (car STATES)))) (MULT-DFS (cdr STATES) PATH)))              
   )
)

; DFS does a depth first search from a given state to the goal state. It
; takes two arguments: a state (S) and the path from the initial state to S
; (PATH). If S is the initial state in our search, PATH is set to NIL. DFS
; performs a depth-first search starting at the given state. It returns the path
; from the initial state to the goal state, if any, or NIL otherwise. DFS is
; responsible for checking if S is already the goal state, as well as for
; ensuring that the depth-first search does not revisit a node already on the
; search path.
(defun DFS (S PATH)
    (cond ((null PATH) (MULT-DFS (SUCC-FN S) (list S)))
          (T (MULT-DFS (SUCC-FN S) PATH))) 
)
    
