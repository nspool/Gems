#lang racket

(require racket/gui/base)

; Timer for display events such as changing the location of the critters

(define event-timer
  (new timer% [notify-callback
               (λ ()
                 (do-next-frame)
                 )] [interval 1000]))

; Display the main window with standard GUI elements for management

(define window-width 640)

(define frame (new (class frame% (super-new)
        (define/augment (on-close)
          (send event-timer stop)
          (displayln "Exiting..."))) (label "Racket Gems") (width window-width) (height 480)))
                                            
; (define frameMsg (new message% (parent frame) (label "No events so far..")))
; (define onclick (λ (button event) (send frameMsg set-label "New label!")))
; (define frameBtn (new button% (parent frame) (label "Click me!") (callback onclick)))

(define playerSprite (read-bitmap "player.png"))
(define gemSprite (read-bitmap "gem.png"))
(define enemySprite (read-bitmap "enemy.png"))
(define leftOffset 0)
(define topOffset 0)

(define score 0)
(define lives 9)
(define frameCount #t)

; Put the gems down around the board

(define gem-width 30)
(define gem-height 30)

; TODO: Positions should be semi-random
(define gem-positions (list '(20 20) '(40 40) '(60 60) '(80 80) '(100 100)))
(define enemy-positions (list '(200 200) '(250 250)))

(define collision? (λ (gemp playerp)
                     (and (> (car playerp) (car gemp)) (> (car (cdr playerp)) (car (cdr gemp)))
                          (< (car playerp) (+ (car gemp) 30)) (< (car (cdr playerp)) (+ (car (cdr gemp)) 30)))))

(define do-next-frame (λ ()
                        (set! frameCount (not frameCount))
                        (if (false? frameCount)
                            (set! enemy-positions (list '(200 200) '(250 250)))
                            (set! enemy-positions (list '(100 100) '(150 150))))
                        (displayln frameCount)
                        (send frame refresh)))
  
(define do-update (λ ()
                    ;; TODO: only do expensive collision detection logic if on the bound
                    (define gem-count (length gem-positions))
                    (define remaining-gems (filter (λ (gemp) (not (collision? (list (- leftOffset 15) (- topOffset 15)) gemp))) gem-positions))
                    (when (< (length remaining-gems) gem-count)
                      (set! gem-positions remaining-gems)
                      (set! score (add1 score)))

                    ;; TODO: collision detection with enemies
                    (define remaining-enemies (filter (λ (enp) (not (collision? (list (- leftOffset 15) (- topOffset 15)) enp))) enemy-positions))
                    (define enemy-count (length enemy-positions))
                    (when (< (length remaining-enemies) enemy-count)
                      (set! enemy-positions remaining-enemies)
                      (set! lives (sub1 lives)))
                    (send frame refresh)))

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
                  (map (λ (tuple) (send dc draw-bitmap gemSprite (car tuple) (car (cdr tuple)))) gem-positions)
                  (map (λ (tuple) (send dc draw-bitmap enemySprite (car tuple) (car (cdr tuple)))) enemy-positions)
                  (send dc set-text-foreground "blue")
                  (send dc draw-line 0 15 window-width 15)
                  (send dc draw-text (format "Score: ~a" score) 0 0)
                  (send dc draw-text (format "Lives: ~a" lives) 100 0)
                  ))

(new my-canvas% (parent frame) (paint-callback onpaint))

(send frame set-cursor (make-object cursor% 'blank))
(send frame show #t)
