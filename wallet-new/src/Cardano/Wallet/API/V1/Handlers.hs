module Cardano.Wallet.API.V1.Handlers (handlers) where

import           Servant
import           Universum

import qualified Cardano.Wallet.API.V1 as V1
import qualified Cardano.Wallet.API.V1.Handlers.Addresses as Addresses
import qualified Cardano.Wallet.API.V1.Handlers.Transactions as Transactions
import qualified Cardano.Wallet.API.V1.Handlers.Wallets as Wallets
import           Cardano.Wallet.WalletLayer.Types (ActiveWalletLayer,
                     walletPassiveLayer)
import           Mockable

handlers :: ActiveWalletLayer Production -> Server V1.API
handlers w =  Addresses.handlers w
         :<|> Wallets.handlers   passiveWallet
         :<|> accounts
         :<|> Transactions.handlers w
         :<|> settings
         :<|> info
  where
    passiveWallet = walletPassiveLayer w

    accounts = todo
    settings = todo
    info = todo

    todo = error "TODO"
