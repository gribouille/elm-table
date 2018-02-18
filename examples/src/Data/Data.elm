module Data.Data exposing (File, User, Log, Level(..))

type alias File =
  { path       : String
  , date       : String
  , permission : String
  }

type alias User =
  { login     : String
  , firstname : String
  , lastname  : String
  , email     : String
  , phone     : String
  }

type alias Log =
  { id      : Int
  , date    : String
  , level   : Level
  , message : String
  }

type Level = Info | Warning | Error | Debug