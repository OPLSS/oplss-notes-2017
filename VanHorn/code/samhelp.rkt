#lang racket
(require redex/reduction-semantics)
(provide (rename-out [subst-1 subst])  ext lookup)

(define-language L
  (T any)
  (M any)
  (b λ μ)
  (X (variable-except λ μ if : N B)))

(define-metafunction L
  [(ext ((any_x : any_τ) ...) (any_x_0 : any_τ_0))
   ((any_x_0 : any_τ_0) (any_x : any_τ) ...)])

(define-metafunction L
  [(lookup ((any_x : any_τ) _ ...) any_x)
   any_τ]
  [(lookup (_ (any_x_0 : any_τ) ...) any_x)
   (lookup ((any_x_0 : any_τ) ...) any_x)])

(define-metafunction L
  subst-1 : X M M -> M
  ;; 1. X_1 bound, so don't continue in body
  [(subst-1 X_1 M_1 (b X_1 T_1 M_2))
   (b X_1 T_1 M_2)]
  
  ;; 2. general purpose capture avoiding case
  [(subst-1 X_1 M_1 (b X_2 T_2 M_2)) 
   (b X_new T_2 (subst-1 X_1 M_1 (subst-vars (X_2 X_new) M_2)))
   (where (X_new) ,(variables-not-in (term (X_1 M_1 M_2)) (term (X_2))))]
   
  ;; 3. replace X_1 with M_1
  [(subst-1 X_1 M_1 X_1) M_1]
  ;; 4. X_1 and X_2 are different, so don't replace
  [(subst-1 X_1 M_1 X_2) X_2]
  ;; the last cases cover all other expressions
  [(subst-1 X_1 M_1 (M_2 ...)) ((subst-1 X_1 M_1 M_2) ...)] 
  [(subst-1 X_1 M_1 M_2) M_2])

(define-metafunction L 
  subst-vars : (X M) ... M -> M
  [(subst-vars (X_1 M_1) X_1) M_1] 
  [(subst-vars (X_1 M_1) (M_2 ...)) 
   ((subst-vars (X_1 M_1) M_2) ...)]
  [(subst-vars (X_1 M_1) M_2) M_2]
  [(subst-vars (X_1 M_1) (X_2 M_2) ... M_3) 
   (subst-vars (X_1 M_1) (subst-vars (X_2 M_2) ... M_3))]
  [(subst-vars M) M])