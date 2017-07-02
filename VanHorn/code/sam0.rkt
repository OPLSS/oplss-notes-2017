#lang racket
(require redex)

(define-language PCF
  (e ::= v
     x
     (either e e)
     (e e)
     (μ x τ e)
     (op e)
     (e op e)
     (if e e e))
  (v ::= b (λ x τ e))
  (b ::= true false n)
  (n ::= number)
  (τ ::= B N (τ → τ))

  (op ::= + is-zero is-odd)
  
  (x ::= variable-not-otherwise-mentioned)

  (Γ ::= ((x : τ) ...))

  (E ::= hole (E e) (v E) (if E e e) (op E) (E op e) (v op E) (either E e) (either v E)))

(define-metafunction PCF
  [(ext ((x_0 : τ_0) ...) (x : τ))
   ((x : τ) (x_0 : τ_0) ...)])

(define-metafunction PCF
  [(lookup ((x : τ) (x_0 : τ_0) ...) x) τ]
  [(lookup ((x_0 : τ_0) (x_1 : τ_1) ...) x)
   (lookup ((x_1 : τ_1) ...) x)])

(define-judgment-form PCF
  #:mode (⊢ I I I O)
  #:contract (⊢ Γ e : τ)
  
  [(⊢ (ext Γ (x : τ)) e : τ_′)
   --------------------------
   (⊢ Γ (λ x τ e) : (τ → τ_′))]

  [(where τ (lookup Γ x))
   ----------------------
   (⊢ Γ x : τ)]

  [(⊢ Γ e_1 : (τ → τ_′))
   (⊢ Γ e_2 : τ)
   ---------------------
   (⊢ Γ (e_1 e_2) : τ_′)]

  [-------------
   (⊢ Γ n : N)]
  
  [-----------
   (⊢ Γ true : B)]
  
  [--------------
   (⊢ Γ false : B)]

  [(⊢ Γ e_1 : B)
   (⊢ Γ e_2 : τ)
   (⊢ Γ e_3 : τ)
   --------------
   (⊢ Γ (if e_1 e_2 e_3) : τ)]

  ;; Not shown
  [(⊢ Γ e : N)
   -----------
   (⊢ Γ (is-zero e) : B)]
  [(⊢ Γ e : N)
   -----------
   (⊢ Γ (is-odd e) : B)]
  [(⊢ Γ e_1 : N)
   (⊢ Γ e_2 : N)
   --------------
   (⊢ Γ (e_1 + e_2) : N)])

(require "sam-help.rkt")

(define r
  (reduction-relation
   PCF
   #:domain e
   (--> ((λ x τ e) v) (subst x v e) β)
   (--> (μ x τ e) (subst x (μ x τ e) e) μ)
   (--> (if true e_1 e_2) e_1 ift)
   (--> (if false e_1 e_2) e_2 iff)
   (--> (n_1 + n_2) ,(+ (term n_1) (term n_2)) plus)
   (--> (either e_1 e_2) e_1)
   (--> (either e_1 e_2) e_2)
   ; Not shown
   (--> (is-zero n) ,(if (zero? (term n)) (term true) (term false)))
   (--> (is-odd n)  ,(if (odd? (term n)) (term true) (term false)))))

(define -->r
  (context-closure r PCF E))

(define -->r′
  (compatible-closure r PCF e))


;;     e r e'
;;-------------
;; E[e] -->r E[e']



