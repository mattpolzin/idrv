module IdvPaths

import public IdvPaths.Generated

import Data.Version
import System.Path
import System.Directory.Extra
import System
import System.File

export
idrisRepoURL : String
idrisRepoURL = "https://github.com/idris-lang/Idris2.git"

export
relativeCheckoutPath : String
relativeCheckoutPath = "checkout"

export
relativeVersionsPath : String
relativeVersionsPath = "versions"

export
relativeBinPath : String
relativeBinPath = "bin"

||| The full path & executable name of the Idris 2
||| binary within the Idv directory (which is a symlink
||| pointing at the actual installed binary of whichever
||| version of Idris 2 is currently selected).
export
idrisSymlinkedPath : String
idrisSymlinkedPath = 
  idvLocation </> relativeBinPath </> "idris2"

||| Get the name of the directory where the given version is installed
||| This is the directory relative to `idvLocation`/`relativeVersionsPath`
export
versionDirName : Version -> String
versionDirName (V major minor patch Nothing _) = "\{show major}_\{show minor}_\{show patch}"
versionDirName (V major minor patch (Just pre) _) = "\{show major}_\{show minor}_\{show patch}-\{pre}"

||| The full path where the given version is installed.
export
versionPath : Version -> String
versionPath version =
  idvLocation </> relativeVersionsPath </> (versionDirName version)

||| The build prefix (PREFIX) to use when making and installing the
||| the given version of the Idris 2 compiler.
export
buildPrefix : Version -> String
buildPrefix = versionPath

||| The full path & executable name of the Idris 2
||| binary within the _versions_ subdirectory of the
||| Idv directory. This is the _actual_ installed binary
||| for the given version that is in turn symlinked to
||| by `idrisSymlinkedPath` when the given version is
||| selected.
export
installedIdrisPath : Version -> String
installedIdrisPath version = 
  versionPath version </> "bin" </> "idris2"

||| The install location of the system copy of Idris 2.
||| If Idris 2 cannot be located on the system (i.e.
||| outside of the Idv versions directory) this function
||| returns Nothing.
export
systemIdrisPath : HasIO io => io (Maybe String)
systemIdrisPath = do
  Nothing <- checkLocation =<< getEnv "IDRIS2"
    | Just envOverride => pure $ Just envOverride
  checkLocation =<< defaultPath
    where
      defaultPath : io (Maybe String)
      defaultPath = pathExpansion defaultIdris2Location

      checkLocation : Maybe String -> io (Maybe String)
      checkLocation Nothing     = pure Nothing
      checkLocation (Just path) = pure $ if !(exists path) then Just path else Nothing

