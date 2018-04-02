#lang racket

(require racket/gui/base)

; Display the main window with standard GUI elements for management

(define frame (new frame% (label "Racket Gems") (width 640) (height 480)))
; (define frameMsg (new message% (parent frame) (label "No events so far..")))
; (define onclick (λ (button event) (send frameMsg set-label "New label!")))
; (define frameBtn (new button% (parent frame) (label "Click me!") (callback onclick)))

(define playerSprite (read-bitmap "player.png"))
(define gemSprite (read-bitmap "gem.png"))
(define leftOffset 0)
(define topOffset 0)

(define score 0)

; Put the gems down around the board
; TODO: Positions should be semi-random
(define gem-positions (list '(20 20) '(40 40) '(60 60) '(80 80) '(100 100)))

(define do-update (λ () (send frame refresh)))

; The custom canvas class
(define my-canvas%
  (class canvas% ; The base class is canvas%
    ; Define overriding method to handle mouse events
    (define/override (on-event event)
      (set! leftOffset (send event get-x))
      (set! topOffset (send event get-y))
      (do-update)
      )
    ; Define overriding method to handle keyboard events
    (define/override (on-char event)
      (case (send event get-key-code)
        ((or #\Q #\q escape)(exit))
         ((up)
          (set! topOffset (- topOffset 10))
          (do-update))
        ((down)
         (set! topOffset (+ topOffset 10))
         (do-update))
        ((right)
         (set! leftOffset (+ leftOffset 10))
         (do-update))
        ((left)
         (set! leftOffset (- leftOffset 10))
         (do-update))
        ))
    ; Call the superclass init, passing on all init args
    (super-new)))

; The main canvas, where we will draw directly

(define onpaint (λ (canvas dc)
                  (send dc draw-bitmap playerSprite leftOffset topOffset)
                  (map (lambda (tuple) (send dc draw-bitmap gemSprite (car tuple) (car (cdr tuple)))) gem-positions) 
                  (send dc draw-text (format "Score: ~a" score) 0 0)
))
(new my-canvas% (parent frame) (paint-callback onpaint))

(send frame set-cursor (make-object cursor% 'blank))
(send frame show #t)
