;; Fantasy Sports League Management Contract - Version 2 (Player Tracking)
;; Built with Clarity on the Stacks Blockchain

;; League ID counter
(define-data-var next-league-id uint u1)

;; Main league data storage
(define-map leagues 
    { id: uint }
    { commissioner: principal, 
      name: (string-ascii 256), 
      prize-distribution: (list 3 uint),
      total-pool: uint,
      total-awarded: uint,
      season-ended: bool })

;; Store individual player data
(define-map players
    { league-id: uint, player: principal }
    { entry-fee: uint })

;; Store league players by index
(define-map league-players
    { league-id: uint, index: uint }
    { player: principal })

;; Store player count per league
(define-map player-counts
    { league-id: uint }
    { count: uint })

;; Validate prize distribution sum equals 100
(define-private (validate-prize-distribution (distribution (list 3 uint)))
    (let ((total (+ (default-to u0 (element-at distribution u0)) 
                   (default-to u0 (element-at distribution u1)) 
                   (default-to u0 (element-at distribution u2)))))
        (is-eq total u100)
    )
)

;; Validate league ID exists
(define-private (validate-league-id (league-id uint))
    (is-some (map-get? leagues { id: league-id }))
)

;; Validate string is not empty
(define-private (validate-non-empty-string (text (string-ascii 256)))
    (not (is-eq text ""))
)

;; Create a new fantasy league
(define-public (create-league (name (string-ascii 256)) (prize-distribution (list 3 uint)))
    (begin
        ;; Validate inputs
        (asserts! (validate-non-empty-string name) (err u400))
        (asserts! (validate-prize-distribution prize-distribution) (err u401))
        
        ;; Create league with validated inputs
        (let ((validated-name name)
              (validated-prize-distribution prize-distribution)
              (league-id (var-get next-league-id)))
            (map-set leagues
                { id: league-id }
                { commissioner: tx-sender,
                  name: validated-name,
                  prize-distribution: validated-prize-distribution,
                  total-pool: u0,
                  total-awarded: u0,
                  season-ended: false })
                  
            (map-set player-counts
                { league-id: league-id }
                { count: u0 })
                
            (var-set next-league-id (+ league-id u1))
            
            (ok league-id)
        )
    )
)

;; Join a league with entry fee
(define-public (join-league (league-id uint) (amount uint))
    (begin
        ;; Validate inputs
        (asserts! (> amount u0) (err u402))
        (asserts! (validate-league-id league-id) (err u100))
        
        ;; Use validated league-id
        (let ((validated-league-id league-id)
              (validated-amount amount)
              (league-data (unwrap-panic (map-get? leagues { id: league-id }))))
            
            ;; Validate league is still active
            (asserts! (not (get season-ended league-data)) (err u403))
            
            ;; Check if player exists
            (if (is-none (map-get? players { league-id: validated-league-id, player: tx-sender }))
                (let ((count-data (default-to { count: u0 } (map-get? player-counts { league-id: validated-league-id }))))
                    (begin
                        ;; Add new player
                        (map-set league-players
                            { league-id: validated-league-id, index: (get count count-data) }
                            { player: tx-sender })
                        
                        ;; Increment count
                        (map-set player-counts
                            { league-id: validated-league-id }
                            { count: (+ (get count count-data) u1) })
                    )
                )
                true
            )
            
            ;; Update player amount
            (map-set players
                { league-id: validated-league-id, player: tx-sender }
                { entry-fee: validated-amount })
            
            ;; Update league total
            (map-set leagues
                { id: validated-league-id }
                { commissioner: (get commissioner league-data),
                  name: (get name league-data),
                  prize-distribution: (get prize-distribution league-data),
                  total-pool: (+ (get total-pool league-data) validated-amount),
                  total-awarded: (get total-awarded league-data),
                  season-ended: (get season-ended league-data) })
            
            (ok true)
        )
    )
)

;; End the fantasy season
(define-public (end-season (league-id uint))
    (begin
        ;; Validate league-id
        (asserts! (validate-league-id league-id) (err u100))
        
        (let ((validated-league-id league-id)
              (league-data (unwrap-panic (map-get? leagues { id: league-id }))))
            
            ;; Validate authorization
            (asserts! (is-eq tx-sender (get commissioner league-data)) (err u102))
            
            ;; Validate season not already ended
            (asserts! (not (get season-ended league-data)) (err u403))
            
            ;; Update season status
            (map-set leagues
                { id: validated-league-id }
                { commissioner: (get commissioner league-data),
                  name: (get name league-data),
                  prize-distribution: (get prize-distribution league-data),
                  total-pool: (get total-pool league-data),
                  total-awarded: (get total-awarded league-data),
                  season-ended: true })
            
            (ok true)
        )
    )
)

;; Get league details
(define-read-only (get-league-details (league-id uint))
    (begin
        (asserts! (validate-league-id league-id) (err u100))
        (ok (unwrap-panic (map-get? leagues { id: league-id })))
    )
)

;; Get player count in a league
(define-read-only (get-player-count (league-id uint))
    (begin
        (asserts! (validate-league-id league-id) (err u100))
        (ok (get count (default-to { count: u0 } (map-get? player-counts { league-id: league-id }))))
    )
)