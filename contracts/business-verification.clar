;; Business Verification Contract
;; Validates legitimate enterprises and stores their information

;; Define data variables
(define-data-var admin principal tx-sender)
(define-map businesses
  { business-id: uint }
  {
    name: (string-utf8 100),
    address: (string-utf8 200),
    registration-number: (string-utf8 50),
    verified: bool,
    owner: principal
  }
)
(define-data-var business-counter uint u0)

;; Error codes
(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_ALREADY_REGISTERED u101)
(define-constant ERR_NOT_FOUND u102)

;; Register a new business
(define-public (register-business (name (string-utf8 100)) (address (string-utf8 200)) (registration-number (string-utf8 50)))
  (let ((business-id (+ (var-get business-counter) u1)))
    (asserts! (is-none (map-get? businesses { business-id: business-id })) (err ERR_ALREADY_REGISTERED))
    (map-set businesses
      { business-id: business-id }
      {
        name: name,
        address: address,
        registration-number: registration-number,
        verified: false,
        owner: tx-sender
      }
    )
    (var-set business-counter business-id)
    (ok business-id)
  )
)

;; Verify a business (admin only)
(define-public (verify-business (business-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR_UNAUTHORIZED))
    (match (map-get? businesses { business-id: business-id })
      business
        (begin
          (map-set businesses
            { business-id: business-id }
            (merge business { verified: true })
          )
          (ok true)
        )
      (err ERR_NOT_FOUND)
    )
  )
)

;; Check if a business is verified
(define-read-only (is-business-verified (business-id uint))
  (match (map-get? businesses { business-id: business-id })
    business (ok (get verified business))
    (err ERR_NOT_FOUND)
  )
)

;; Get business details
(define-read-only (get-business (business-id uint))
  (match (map-get? businesses { business-id: business-id })
    business (ok business)
    (err ERR_NOT_FOUND)
  )
)

;; Transfer admin rights
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR_UNAUTHORIZED))
    (var-set admin new-admin)
    (ok true)
  )
)

