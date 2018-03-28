#lang racket

(require racket/draw)
(require racket/gui/base)

(define frame (new frame% (label "Drawing Shapes") (width 640) (height 480)))

(define onpaint (λ (canvas dc)
                  (send dc set-scale 3 3)
                  (send dc set-text-foreground "blue")
                  (send dc draw-line 50 50 100 100)
                  (send dc draw-text "Don't Panic!" 0 0)
))

(new canvas% (parent frame) (paint-callback onpaint))

(send frame show #t)
