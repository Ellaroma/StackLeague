;; Fantasy Sports League Management Contract - Version 1 (MVP)
;; Built with Clarity on the Stacks Blockchain

;; League ID counter
(define-data-var next-league-id uint u1)

;; Main league data storage
(define-map leagues 
    { id: uint }
    { commissioner: principal, 
      name: (string-ascii 256), 
      prize-distribution: (list 3 uint),
      total-pool: uint })

;; Store individual player data
(define-map players
    { league-id: uint, player: principal }
    { entry-fee: uint })

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
                  total-pool: u0 })
                  
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
                  total-pool: (+ (get total-pool league-data) validated-amount) })
            
            (ok true)
        )
    )
)