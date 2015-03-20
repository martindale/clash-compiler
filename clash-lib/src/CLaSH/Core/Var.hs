{-# LANGUAGE CPP                   #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE UndecidableInstances  #-}

-- | Variables in CoreHW
module CLaSH.Core.Var
  ( Var (..)
  , Id
  , TyVar
  , modifyVarName
  )
where

import Control.DeepSeq                  (NFData (..))
import Data.Typeable                    (Typeable)
import GHC.Generics                     (Generic)
import Unbound.Generics.LocallyNameless (Alpha,Embed,Name,Subst(..),isFreeName)
import Unbound.Generics.LocallyNameless.Extra ()

import {-# SOURCE #-} CLaSH.Core.Term   (Term)
import {-# SOURCE #-} CLaSH.Core.Type   (Kind, Type)
import CLaSH.Util

-- | Variables in CoreHW
data Var a
  -- | Constructor for type variables
  = TyVar
  { varName :: Name a
  , varKind :: Embed Kind
  }
  -- | Constructor for term variables
  | Id
  { varName :: Name a
  , varType :: Embed Type
  }
  deriving (Eq,Show,Generic,Typeable,NFData)

-- | Term variable
type Id    = Var Term
-- | Type variable
type TyVar = Var Type

instance (Typeable a, Alpha a) => Alpha (Var a)

instance Subst Term Id
instance Subst Term TyVar

instance Subst Type TyVar
instance Subst Type Id where
  subst tvN u (Id idN ty) | isFreeName tvN = Id idN (subst tvN u ty)
  subst m _ _ = error $ $(curLoc) ++ "Cannot substitute for bound variable: " ++ show m

-- | Change the name of a variable
modifyVarName ::
  (Name a -> Name a)
  -> Var a
  -> Var a
modifyVarName f (TyVar n k) = TyVar (f n) k
modifyVarName f (Id n t)    = Id (f n) t
