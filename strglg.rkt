#lang racket/base
(require racket/function
         racket/list)

(define (~ . xs) (foldl compose (last xs) (cdr (reverse xs))))

(struct la (ins cont) #:transparent)
(struct fn (name ins) #:transparent) 
; `fn' is the lowest level. always confirmed simplest form.
; these functions cannot be partially applied at top-level.
(struct exp (h t) #:transparent) ; LISP-style s-expression. (lambda . args-list)
(struct apl (h t) #:transparent)
(struct v (val type) #:transparent)
(define (sym? s) (and (v? s) (equal? (v? s) "Sym")))
(define (ins lf) (if (la? lf) (length (la-ins lf)) (fn-ins lf)))

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (car (reverse stk)))
(define (ret-pop stk) (reverse (cdr (reverse stk))))
(define (strcar str) (car (string->list str)))

(define funs (list (fn "+" 2)))

; ac-expr is the expression that is used on every element of `lst' but preserves the original `lst'.
(define (find-eq a ac-expr lst) (findf (λ (x) (equal? a (ac-expr x))) lst))

(define (mk-args n) (for/list ([i n]) (list->string (list #\a (integer->char (+ i 48))))))
(define (argsn e) (- (ins (exp-h e)) (length (exp-t e))))
#;(define (move-args t x n)
  (cond [(empty? t) n]
        [(la? (car t)) (move-args (cdr t) (drop x (ins (car t))) 
                                  (push n (exp (exp-h (la-cont (car t)))
                                               (repla))))]
        [else (move-args (cdr t) (push n (car t)))]))
#;(define (exp->la e) (let ([x #;(mk-args (argsn e))
                             (mk-args (foldl (λ (x y) (if (la? x) (+ (ins x) y) y)) (argsn e) (exp-t e)))])
  (la x #;(exp (exp-h e) (if (not (empty? (exp-t e))) 
                           ((car (exp-t e)) x)))
      (if (or (empty? (exp-t e)) (not (la? (car (exp-t e))))) (exp (exp-h e) x)
          (exp (if (list? (car (exp-t e))) (append (list (exp-h e)) (car (exp-t e)))
                   (list (exp-h e) (car (exp-t e)))) x)))
               
  #;(la x (exp (exp-h e) (append (exp-t e) x)))))

(define (exp->la e) (let ([x (if (and (= (length (exp-t e)) 1) (la? (car (exp-t e))))
                                 (exp-h (la-cont (car (exp-t e)))) #f)]
                          [y (mk-args (foldl (λ (x y) (if (la? x) (+ (ins x) y) y)) (argsn e) (exp-t e)))])
  (la y (exp (if x (if (list? x) (append (list (exp-h e)) x) (list (exp-h e) (car (exp-t e))))
                 (exp-h e)) y))))

#;(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (splt (string->list str) '(())))))
(define (splt str n) (let ([q (if (empty? str) #f (member (car str) (list #\( #\) #\{ #\} #\[ #\] #\:)))])
  (cond [(empty? str) n] ;[(empty? n) (splt (cdr str) (if (char-whitespace? (car str)) n (push n (car str))))]
        [(empty? (pop n)) (splt (cdr str) (if (char-whitespace? (car str)) 
                                              n (if q (append n (list (list (car str)) '())) (push (ret-pop n) (push (pop n) (car str))))))]
        [(char=? (car str) #\") (if (char=? (car (pop n)) #\") 
                                    (splt (cdr str) (append (ret-pop n) (list (push (pop n) #\") '()))) 
                                    (splt (cdr str) (push n (list #\"))))]
        [(char=? (car (pop n)) #\") (splt (cdr str) (push (ret-pop n) (push (pop n) (car str))))]
        [(char-whitespace? (car str)) (splt (cdr str) (push n '()))]
        [q (splt (cdr str) (append n (list (list (car str)) '())))]
        [else (splt (cdr str) (push (ret-pop n) (push (pop n) (car str))))])))

(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (foldl (λ (s n)
  (cond [(equal? (car n) 'str) (if (equal? s #\") (push (second n) '()) (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\] #\:)) (append n (list (list s)) (list '()))]
        [(equal? s #\space) (push n '())] [else (push (ret-pop n) (push (pop n) s))])) '(()) (string->list str)))))

#;(define (check-parens stk) (map rem-plist (cp stk '())))
(define (cp stk n)
  (cond [(empty? stk) n]
        [(equal? (v-type (car stk)) "$close") (let* ([c (case (v-val (car stk)) [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                                                     [l (λ (x) (not (equal? (v-val x) c)))])
           (cp (cdr stk) (push (ret-pop (reverse (dropf (reverse n) l))) (v (reverse (takef (reverse n) l))
                                                                            (case c [("{") "Union"] [("[") "List"] [("(") "PList"] [else '()])))))]
        [else (cp (cdr stk) (push n (car stk)))]))
(define (rem-plist a) (if (equal? (v-type a) "PList") (map rem-plist (v-val a))
                          (if (equal? (v-type a) "List") (v (map rem-plist (v-val a)) "List") a)))

(define (check-parens lst) (foldl (λ (elt n)
  (if (or (empty? n) (not (equal? elt ")"))) (push n elt)
      (let* ([c (case elt [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                          [expr (λ (x) (not (equal? x c)))])
        (push (ret-pop (reverse (dropf (reverse n) expr))) (reverse (takef (reverse n) expr)))))) '() lst))

(define (lex s)
  (cond [(member s (list "(" ")" "{" "}" "[" "]" ":")) s]
        [(member s (map fn-name funs)) (find-eq s fn-name funs)] [else (v s "Lit")]))

(define (parsel lst) (reverse (foldr (λ (lt lts n) (begin #;(map displayln (list lt lts))
  (cond [(and (not (empty? n)) (equal? (car n) 'just)) (second n)]
        [(fn? lt) (list (exp->la (exp lt (reverse n))))]
        [(list? lt) (append n (parsel lt))]
        [(equal? lt ":") (let ([x (if (list? lts) (car (parsel lts)) lts)])
          (if (not (= 0 (argsn (exp x n)))) 
              (begin (printf "mis-matched application: `~a' requires ~a arguments; given ~a.~n" 
                             (if (la? x) x (fn-name x)) (ins x) (length n)) '())
              (list 'just (list (apl x (reverse n))))))]
        [else (push n lt)]))) '() lst (append (list (pop lst)) (ret-pop lst)))))
          
(define (parse str) (parsel (check-parens (map lex (string-split-spec str)))))