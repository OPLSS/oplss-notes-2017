#lang racket
(require redex)

;; TBA - Typed Language of Boolean and Arithmetic Expressions

;; Natural Numbers
(define (>0 n)
  (> n 0))


;; Syntax

;; e ∈ TBA ; n ∈ ℕ ; b ∈ BOOL ; p ∈ PROG
;; v ∈ VALUE ; w ∈ CANON ; r ∈ REDEX ⊆ PROG ; f ∈ FAULTY ; c ∈ CONTRACTUM
;; E ∈ ECTXT
(define-language TBA
  (e ::= n (pred e) (succ e) (zero? e)
     b (if e e e))
  (n ::= natural)
  (b ::= true false)
  (τ ::= NAT BOOL)
  (p ::= (side-condition e_1 (judgment-holds (⊢ e_1 : τ))))
  (v ::= n b)
  (w ::= v err)
  (r ::= (pred v) (succ v) (zero? v) (if v p p))
  ;(f ::= (if n e e) (pred b) (succ b) (zero? b))
  (err ::= underflow #;mismatch)
  (c ::= p err)
  (E ::= hole (pred E) (succ E) (zero? E) (if E p p)))

;; Type System
(define-judgment-form TBA
  #:mode (⊢ I I O)
  #:contract (⊢ e : τ)
  [---------------
   (⊢ true : BOOL)]
  
  [---------------
   (⊢ false : BOOL)]
  
  [---------------
   (⊢ n : NAT)]
  
  [(⊢ e_1 : BOOL)
   (⊢ e_2 : τ)
   (⊢ e_3 : τ)
   --------------
   (⊢ (if e_1 e_2 e_3) : τ)]

  [(⊢ e : NAT)
   -----------
   (⊢ (succ e) : NAT)]

  [(⊢ e : NAT)
   -----------
   (⊢ (pred e) : NAT)]

  [(⊢ e : NAT)
   -----------
   (⊢ (zero? e) : BOOL)]
  )

(test-equal (judgment-holds (⊢ (if true 3 4) : τ)) #t)

;; Notions of reduction (↝ is Unicode 219D)
;; ↝ ⊆ (REDEX \ FAULTY) × PROG
(define ↝
  (reduction-relation
   TBA
   #:domain c ;; overapproximation :(
   (--> (if true p_2 p_3) p_2)
   (--> (if false p_2 p_3) p_3)
   (--> (pred n) ,(sub1 (term n)) (side-condition (>0 (term n))))
   (--> (succ n) ,(add1 (term n)))
   (--> (zero? 0) true)
   (--> (zero? n) false (side-condition (>0 (term n))))))


;; context closure rules
;; -->E ⊆ PROG × PROG
(define -->E
  (context-closure ↝ TBA E))


;; context-eating error rules
;; -->err ⊆ PROG × ERR
(define -->err
  (reduction-relation
   TBA
   #:domain c ;; overapproximation :(
   (--> (in-hole E (pred 0)) underflow)
   #;(--> (in-hole E f) mismatch)))


;; full reduction relation
;; -->r ⊆ PROG \times (PROG ∪ ERR)
(define -->r
  (union-reduction-relations
   -->E
   -->err))   


;; Rendering-related stuff
(rule-pict-style 'horizontal)


;; To see a trace, e.g.:
;(traces -->r (term (if true 3 4)))
;(traces (term (if (succ false) true 4)))

;; Some Tests
(test-equal (redex-match? TBA e (term (if true 3 4))) #t)

(test-->> -->r (term (if true 3 4)) (term 3))
(test-->> -->r (term (if false 3 4)) (term 4))

(test-->> -->r (term (if true (succ 2) 4)) (term 3))
(test-->> -->r (term (pred (pred 1))) (term underflow))

;; THESE ARE NOT TBA PROGRAMS!
;(test-->> -->r (term (if true 3 false)) (term 3))
;(test-->> -->r (term (if false 3 false)) (term false))
;(test-->> -->r (term (if true (succ false) 4)) (term mismatch))

;; go straight to error
;(test-->> -->r (term (if (succ false) true 4)) (term mismatch))


;; Joys of Testing

;; uniquely-reduces?:  my configuration reduce to one and only one thing
(define (uniquely-reduces? c)
  (= 1 (length (apply-reduction-relation -->r c))))

;; unique-progress?:  either I'm done or I reduce to one and oonly one thing.
(define (unique-progress? c)
  (or (redex-match? TBA w c)
      (uniquely-reduces? c)))

;; Dear Redex: please invent 10,000 Programs p and check unique-progress
;(redex-check TBA p (unique-progress? (term p)) #:attempts 10000)