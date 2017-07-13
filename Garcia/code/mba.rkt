#lang racket
(require redex)
(provide (all-defined-out))

;; MBA - Mixed Language of Boolean and Arithmetic Expressions
;; Now with static ascription!

;; Natural Numbers
(define (>0 n)
  (> n 0))


;; Syntax
;; from-s ==> ⌊⌋ (U+230A U+230B)
;; from-d ==> ⌈⌉ (U+2308 U+2309) 

;; d ∈ DBA ; s ∈ SBA ; n ∈ ℕ ; b ∈ BOOL ; p ∈ PROG
;; v ∈ VALUE ; w ∈ CANON ; r ∈ REDEX ⊆ PROG ; f ∈ FAULTY ⊆ DBA ; c ∈ CONTRACTUM
;; Es ∈ SECTXT ; Ed ∈ DECTXT
(define-language MBA
  (s ::= n (pred s) (succ s) (zero? s) b (if s s s) (:: s τ) (from-d d))
  (d ::= n (pred d) (succ d) (zero? d) b (if d d d) (from-s s))
  (n ::= natural)
  (b ::= true false)
  (τs ::= NAT BOOL)
  (τ ::= τs)
  (ps ::= (side-condition s_1 (judgment-holds (⊢S s_1 : τs))))
  (pd ::= (side-condition d_1 (judgment-holds (⊢D d_1 ok))))
  (u ::= n b)
  (vs ::= u (from-d u)) ;; n b (from-d n) (from-d b))
  (vd ::= u (from-s u)) ;;n b (from-s n) (from-s b))
  (v ::= vs vd)
  (w ::= v err)
  (r ::= (pred v) (succ v) (zero? v) (if v p p))
  (fd ::= (if n d d) (pred b) (succ b) (zero? b)
      (if (from-s n) d d) (pred (from-s b)) (succ (from-s b))
      (zero? (from-s b)))
  (fs ::=
      (if (from-d n) s s) (pred (from-d b)) (succ (from-d b)) (zero? (from-d b))
      (:: (from-d b) NAT) (:: (from-d n) BOOL))
  (err ::= underflow mismatch)
  (c ::= ps pd err)
  ;(Es ::= hole (pred Es) (succ Es) (zero? Es) (if Es s s) (from-d Ed))
  ;(Ed ::= hole (pred Ed) (succ Ed) (zero? Ed) (if Ed d d) (from-s Es))

  ;; Exy : context that produces X code when plugged with Y code
  (Ess ::= hole (pred Ess) (succ Ess) (zero? Ess) (if Ess s s) (from-d Eds)
       (:: Ess τ))
  (Esd ::=      (pred Esd) (succ Esd) (zero? Esd) (if Esd s s) (from-d Edd)
       (:: Esd τ))
  (Eds ::=      (pred Eds) (succ Eds) (zero? Eds) (if Eds d d) (from-s Ess))
  (Edd ::= hole (pred Edd) (succ Edd) (zero? Edd) (if Edd d d) (from-s Esd))

  (E ::= Ess Esd) ;; default to static language
  (p ::= ps)      ;; default to the static language
  )

;; Type System
(define-judgment-form MBA
  #:mode (⊢S I I O)
  #:contract (⊢S s : τs)
  [---------------
   (⊢S true : BOOL)]
  
  [---------------
   (⊢S false : BOOL)]
  
  [---------------
   (⊢S n : NAT)]
  [(⊢S s_1 : BOOL)
   (⊢S s_2 : τ)
   (⊢S s_3 : τ)
   --------------
   (⊢S (if s_1 s_2 s_3) : τ)]

  [(⊢S s : NAT)
   -----------
   (⊢S (succ s) : NAT)]

  [(⊢S s : NAT)
   -----------
   (⊢S (pred s) : NAT)]

  [(⊢S s : NAT)
   -----------
   (⊢S (zero? s) : BOOL)]

  [(⊢S s : τ)
   ----------
   (⊢S (:: s τ) : τ)]

  [(⊢D d ok)
   ---------------------
   (⊢S (from-d d) : NAT)]

  [(⊢D d ok)
   -----------------------
   (⊢S (from-d d) : BOOL)]
  )

(define-judgment-form MBA
  #:mode (⊢D I I)
  #:contract (⊢D d ok)
  [---------------
   (⊢D true ok)]
  
  [---------------
   (⊢D false ok)]
  
  [---------------
   (⊢D n ok)]
  
  [(⊢D d_1 ok)
   (⊢D d_2 ok)
   (⊢D d_3 ok)
   --------------
   (⊢D (if d_1 d_2 d_3) ok)]

  [(⊢D d ok)
   -----------
   (⊢D (succ d) ok)]

  [(⊢D d ok)
   -----------
   (⊢D (pred d) ok)]

  [(⊢D d ok)
   -----------
   (⊢D (zero? d) ok)]

  [(⊢S s : τ)
   ------------------
   (⊢D (from-s s) ok)]
  )

(test-equal (judgment-holds (⊢S (if true 3 4) : τ)) #t)

(test-equal (judgment-holds (⊢D (if true 3 4) ok)) #t)

;; Notions of reduction (↝ is Unicode 219D)
;;↝xy = reductions for px terms that deal with immediate px subterms

;; ↝s ⊆ (REDEX \ FAULTY) × PROG
(define ↝ss
  (reduction-relation
   MBA
   #:domain c ;; overapproximation :(
   (--> (if true ps_2 ps_3) ps_2)
   (--> (if false ps_2 ps_3) ps_3)
   (--> (pred n) ,(sub1 (term n)) (side-condition (>0 (term n))))
   (--> (succ n) ,(add1 (term n)))
   (--> (zero? 0) true)
   (--> (zero? n) false (side-condition (>0 (term n))))
   (--> (:: n NAT) n)
   (--> (:: b BOOL) b)))

(define ↝sd
  (reduction-relation
   MBA
   #:domain c ;; overapproximation :(
   (--> (if (from-d true) ps_2 ps_3) ps_2)
   (--> (if (from-d false) ps_2 ps_3) ps_3)
   (--> (pred (from-d n)) ,(sub1 (term n)) (side-condition (>0 (term n))))
   (--> (succ (from-d n)) ,(add1 (term n)))
   (--> (zero? (from-d 0)) true)
   (--> (zero? (from-d n)) false (side-condition (>0 (term n))))
   (--> (from-d (from-s u)) u)  ;; ?!?!?!?
   (--> (:: (from-d n) NAT) n)
   (--> (:: (from-d b) BOOL) b)))

(define ↝s
  (union-reduction-relations ↝ss ↝sd))

(define -->s
  (context-closure ↝s MBA Ess))


;; ↝d ⊆ (REDEX \ FAULTY) × PROG
(define ↝dd
  (reduction-relation
   MBA
   #:domain c ;; overapproximation :(
   (--> (if true pd_2 pd_3) pd_2)
   (--> (if false pd_2 pd_3) pd_3)
   (--> (pred n) ,(sub1 (term n)) (side-condition (>0 (term n))))
   (--> (succ n) ,(add1 (term n)))
   (--> (zero? 0) true)
   (--> (zero? n) false (side-condition (>0 (term n))))))

(define ↝ds
  (reduction-relation
   MBA
   #:domain c ;; overapproximation :(
   (--> (if (from-s true) pd_2 pd_3) pd_2)
   (--> (if (from-s false) pd_2 pd_3) pd_3)
   (--> (pred (from-s n)) ,(sub1 (term n)) (side-condition (>0 (term n))))
   (--> (succ (from-s n)) ,(add1 (term n)))
   (--> (zero? (from-s 0)) true)
   (--> (zero? (from-s n)) false (side-condition (>0 (term n))))
   (--> (from-s (from-d u)) u))   
  )

(define ↝d
  (union-reduction-relations ↝dd ↝ds))

(define -->d
  (context-closure ↝d MBA Esd))

;; context closure rules
;; -->E ⊆ PROG × PROG
(define -->E
  (union-reduction-relations -->s -->d))


;; context-eating error rules
;; -->err ⊆ PROG × ERR
(define -->serr
  (reduction-relation
   MBA
   #:domain c ;; overapproximation :(
   (--> (in-hole Ess (pred 0)) underflow)
   (--> (in-hole Ess (pred (from-d 0))) underflow)
   (--> (in-hole Ess fs) mismatch)))

(define -->derr
  (reduction-relation
   MBA
   #:domain c ;; overapproximation :(
   (--> (in-hole Esd (pred 0)) underflow)
   (--> (in-hole Esd (pred (from-s 0))) underflow)
   (--> (in-hole Esd fd) mismatch)))

(define -->err
  (union-reduction-relations -->serr -->derr))


;; full reduction relation
;; -->r ⊆ PROG \times (PROG ∪ ERR)
(define -->r
  (union-reduction-relations
   -->E
   -->err))   


;; Rendering-related stuff

;; How to render a derivation tree of a judgment
(define-syntax render-derivations
  (syntax-rules ()
    [(_ j) 
     (show-derivations
      (build-derivations j))]))
    


(rule-pict-style 'horizontal)

;; To see a trace, e.g.:
;(traces -->r (term (if true 3 4)))
;(traces (term (if (succ false) true 4)))

;; Some Tests
(test-equal (redex-match? MBA pd (term (if true 3 4))) #t)
(test-equal (redex-match? MBA ps (term (if true 3 4))) #t)

(test-->> -->r (term (if true 3 4)) (term 3))
(test-->> -->r (term (if false 3 4)) (term 4))

(test-->> -->r (term (if true (succ 2) 4)) (term 3))
(test-->> -->r (term (pred (pred 1))) (term underflow))

;; THESE ARE NOT PROGRAMS!
;(test-->> -->r (term (if true 3 false)) (term 3))
;(test-->> -->r (term (if false 3 false)) (term false))
;(test-->> -->r (term (if true (succ false) 4)) (term mismatch))

;; go straight to error
;(test-->> -->r (term (if (succ false) true 4)) (term mismatch))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fun with mixed programs!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; What counts as a program?
(test-equal (redex-match? MBA p (term (if true 3 7))) #t)
(test-equal (redex-match? MBA p (term (if true 3 false))) #f)
(test-equal (redex-match? MBA p (term (from-d (if true 3 false)))) #t)
(test-equal (redex-match? MBA p (term (if true (from-d 3) false))) #t)
(test-equal (redex-match? MBA p (term (if true 3 (from-d false)))) #t)

(test-equal (judgment-holds (⊢S (from-d (if true 3 false)) : τ) τ) '(BOOL NAT))
(test-equal (judgment-holds (⊢S (if true (from-d 3) false) : τ) τ) '(BOOL))
(test-equal (judgment-holds (⊢S (if true 3 (from-d false)) : τ) τ) '(NAT))

(test-->>∃ -->r (term (if (:: (from-d false) BOOL) true false)) (term false))

;(render-derivations (⊢S (if false 3 (from-d false)) : τ))

;(apply-reduction-relation -->r (term (if false 3 (from-d false))))

;(define x
; (first (apply-reduction-relation -->r (term (if false 3 (from-d false))))))
; (render-derivations (⊢S ,x : τ))

;(traces -->r (term (if (:: (from-d 7) BOOL) true false)))
;(render-derivations (⊢S (if (:: (from-d 7) BOOL) true false) : τ))


#;
(for/list ([i (in-range 10)])
    (generate-term MBA s 5))

#;
(for/list ([i (in-range 10)])
    (generate-term MBA #:satisfying (⊢S s_1 : NAT) 3))

#;
(for-each (λ (p) (traces -->r p))
          (for/list ([i (in-range 10)])
            (generate-term MBA s 5)))


;; Joys of Testing

;; uniquely-reduces?:  my configuration reduce to one and only one thing
(define (uniquely-reduces? c)
  (= 1 (length (apply-reduction-relation -->r c))))

;; unique-progress?:  either I'm done or I reduce to one and only one thing.
(define (unique-progress? c)
  (or (redex-match? MBA w c)
      (uniquely-reduces? c)))

;; Dear Redex: please invent 10,000 Programs p and check unique-progress
;(redex-check MBA p (unique-progress? (term p)) #:attempts 10000)





