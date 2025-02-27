# StackLeague: Fantasy Sports on Stacks

StackLeague is a decentralized fantasy sports league management system built on the Stacks blockchain using Clarity smart contracts. It enables the creation, management, and prize distribution for fantasy sports leagues in a transparent and trustless manner.

## Features

- **League Creation**: Commissioners can create new fantasy leagues with customizable prize distributions
- **Player Participation**: Users can join leagues by paying entry fees
- **Season Management**: Commissioners can mark seasons as ended when appropriate
- **Ranking System**: Commissioners can assign rankings to players based on performance
- **Automated Prize Distribution**: Smart contract handles prize distribution based on final rankings
- **Event Tracking**: All significant actions are recorded as events for transparency
- **Read-Only Functions**: Various functions to query league details, player information, and winners

## Smart Contract Functions

### Administrative Functions

- `create-league`: Create a new fantasy league with a name and prize distribution
- `end-season`: Mark a league's season as ended
- `set-player-rank`: Assign a rank to a player after the season ends
- `distribute-prizes`: Distribute prize money according to rankings and prize distribution

### Player Functions

- `join-league`: Join a league by paying an entry fee

### Read-Only Functions

- `get-league-details`: Get details about a specific league
- `get-player-count`: Get the number of players in a league
- `get-player-details`: Get details about a specific player in a league
- `get-winner`: Get information about the winner for a specific rank
- `get-latest-events`: Get the most recent events from the contract

## Prize Distribution

The contract supports a three-tiered prize distribution system:
- First place: Configurable percentage of the total pool
- Second place: Configurable percentage of the total pool
- Third place: Configurable percentage of the total pool

The prize distribution percentages must sum to 100.

## Error Codes

| Code | Description |
|------|-------------|
| u100 | Invalid league ID |
| u102 | Not authorized (not the commissioner) |
| u400 | Invalid league name (empty) |
| u401 | Invalid prize distribution (must sum to 100) |
| u402 | Invalid entry fee amount (must be greater than 0) |
| u403 | Season already ended |
| u404 | Season not ended yet |
| u405 | League already finalized |
| u406 | Player not found in league |
| u407 | Prizes already distributed |
| u408 | Winner not found for specified rank |

## Usage Example

```clarity
;; Create a new league with 50/30/20 prize distribution
(contract-call? .stackleague create-league "NFL Fantasy 2025" (list u50 u30 u20))

;; Join a league with 100 STX entry fee
(contract-call? .stackleague join-league u1 u100)

;; End the season (commissioner only)
(contract-call? .stackleague end-season u1)

;; Set player rankings (commissioner only)
(contract-call? .stackleague set-player-rank u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u1)
(contract-call? .stackleague set-player-rank u1 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG u2)
(contract-call? .stackleague set-player-rank u1 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC u3)

;; Distribute prizes (commissioner only)
(contract-call? .stackleague distribute-prizes u1)