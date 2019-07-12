module Snap.Snaplet.Hasql
  ( HasHasql(..)
  , Hasql(..)
  , hasqlInit
  , withHasql
  , runHasql
  ) where

import           Control.Monad.Trans        (MonadIO, liftIO)
import qualified Data.Configurator          as C
import qualified Data.Configurator.Types    as C
import           Hasql.Connection           (settings)
import           Hasql.Pool                 (Pool, Settings, UsageError,
                                             acquire, release, use)
import qualified Hasql.Session              as HS
import           Hasql.Statement            (Statement)
import           Paths_snaplet_hasql_simple (getDataDir)
import           Snap.Snaplet               (SnapletInit, getSnapletUserConfig,
                                             makeSnaplet, onUnload)

class MonadIO m => HasHasql m where
  getHasql :: m Hasql

newtype Hasql = Hasql Pool

hasqlInit :: SnapletInit b Hasql
hasqlInit = makeSnaplet "hasql" description dataDir $ do
  hasqlSettings <- getSettings =<< getSnapletUserConfig
  pool <- liftIO $ acquire hasqlSettings
  onUnload $ release pool
  return $ Hasql pool
  where
    description = "hasql pool"
    dataDir = Just $ (<>"/resources/db") <$> getDataDir

withHasql :: HasHasql m => (Hasql -> m a) -> m a
withHasql = (=<< getHasql)

runHasql :: HasHasql m => Statement a b -> a -> m (Either UsageError b)
runHasql statement input =
  withHasql $ \(Hasql pool) -> liftIO (use pool sess)
  where
    sess = HS.statement input statement

getSettings :: MonadIO m => C.Config -> m Settings
getSettings config = liftIO $ do
  size <- C.lookupDefault 1 config "size"
  duration <- fromInteger <$> C.lookupDefault 30 config "duration"
  host <- C.lookupDefault "127.0.0.1" config "host"
  port <- C.lookupDefault 5432 config "port"
  username <- C.lookupDefault "" config "username"
  password <- C.lookupDefault "" config "password"
  name <- C.require config "name"
  return (size, duration, settings host port username password name)
