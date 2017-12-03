#lang racket

(require racket/gui/base)

; Display the main window with standard GUI elements for management

(define frame (new frame% (label "Racket Gems") (width 640) (height 480)))
; (define frameMsg (new message% (parent frame) (label "No events so far..")))
; (define onclick (λ (button event) (send frameMsg set-label "New label!")))
; (define frameBtn (new button% (parent frame) (label "Click me!") (callback onclick)))

(define sprite (read-bitmap "placeholder.png"))
(define gemSprite (read-bitmap "placeholder.png"))
(define leftOffset 0)
(define topOffset 0)

; The custom canvas class
(define my-canvas%
  (class canvas% ; The base class is canvas%
    ; Define overriding method to handle mouse events
    (define/override (on-event event)
      (set! leftOffset (send event get-x))
      (set! topOffset (send event get-y))
      (send frame refresh)
      )
    ; Define overriding method to handle keyboard events
    (define/override (on-char event)
      (case (send event get-key-code)
        ((or #\Q #\q escape)(exit))
         ((up)(set! topOffset (- topOffset 10))(send frame refresh))
        ((down)(set! topOffset (+ topOffset 10))(send frame refresh))
        ((right)
         ; (send frameMsg set-label "Move Right") 
         (set! leftOffset (+ leftOffset 10))
         (send frame refresh))
        ((left)
         ; (send frameMsg set-label "Move Left")
         (set! leftOffset (- leftOffset 10))
         (send frame refresh))
        ; ((control) (send frameMsg set-label "control"))
        ; ((shift) (send frameMsg set-label "shift"))
        ; ((#\space) (send frameMsg set-label "space"))
        ))
    ; Call the superclass init, passing on all init args
    (super-new)))

; The main canvas, where we will draw directly

(define onpaint (λ (canvas dc)
                  ; (send dc set-scale 3 3)
                  ; (send dc set-text-foreground "blue")
                   (send dc draw-bitmap sprite leftOffset topOffset)
                  ; (send dc draw-text "Don't Panic!" 0 0)
))
(new my-canvas% (parent frame) (paint-callback onpaint))

(send frame set-cursor (make-object cursor% 'blank))
(send frame show #t)
