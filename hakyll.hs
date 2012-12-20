{-# LANGUAGE OverloadedStrings #-}
import Control.Arrow ((>>>), (***), (&&&), (|||), arr, first, second)
import Data.Monoid (Monoid, mconcat, mempty)
import Prelude hiding (id)
import Control.Category (id)
import Hakyll
-- import Hakyll.Core.Util.File.getRecursiveContent
import Data.Char (toUpper)
import Data.Text (pack, unpack, replace)
import System.Directory (copyFile, removeFile)
-- For f x = g x x in prettyURLs
import Control.Monad (join, forM_, forM)



-- Paramaters
allowableURLCharacters = ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9']
tempPostsDirectory = "tmp_posts/"
tempPostsPattern = parseGlob $ tempPostsDirectory++"**"
logFirstSize = 2
logNextSize = 2

main :: IO ()
main = (renamePosts >>) . hakyll $ do
    -- CSS (ignore LESS files)
    match "static/css/*.css" $ do
        route   idRoute
        compile compressCssCompiler
    
    -- JavaScript
    match "static/js/*" $ do
        route   idRoute
        compile copyFileCompiler

    -- Images
    match "static/images/*" $ do
        route   idRoute
        compile copyFileCompiler
    
    -- HTML templates
    match "templates/*" $ compile templateCompiler
        
    -- This stops a cyclic dependency (somehow!)
    posts <- group "posts" $ match tempPostsPattern $ do
                  compile $ pageCompiler
                    -- We have to fix URL metadata, since this is used
                    --   when generating the Log
                    >>> fixURLs
                    >>> relativizeUrlsCompiler
    
    -- Applied to (almost) every site page
    let universalCompiler = pageCompiler
                            >>> requireAllA posts addLogItems
                            >>> setLocation
                            >>> applyTemplateCompiler "templates/default.html"
                            >>> relativizeUrlsCompiler


    -- Pages
    match "pages/**" $ do
        route   $ gsubRoute "pages/" (const "")
          `composeRoutes` setExtension ".html"
          `composeRoutes` prettyURLs
        compile $ universalCompiler
    
    -- Posts
    match tempPostsPattern $ do
        route   $ setExtension ".html"
          `composeRoutes` gsubRoute tempPostsDirectory (const "posts/")  
          `composeRoutes` prettyURLs
        compile $ universalCompiler

-- Possibly set the page location, if not user-set
setLocation :: Compiler (Page String) (Page String)
setLocation = arr $ \x -> trySetField "location" (nice_location x) x
  where nice_location = tryStripSlash
                        . (\ (y,_,_) -> y)
                        . filePathExplode
                        . getField "url"
        tryStripSlash = reverse . dropWhile (=='/') . reverse

-- Possibly add comments, defaulting to yes
--addComments :: Compiler (Page String) (Either (Page String) (Page String))
--addComments = arr $ \p -> if getBoolVariable "comments" True p
--                          then Left p
--                          else Right p
--              >>> (arr $ setField "comments" "COMMENTS ENABLED"
--                   ||| arr $ setField "comments" "COMMENTS DISABLED")


-- Generate nice URLS for pages by putting them in folders
-- We treat the index page as a special case.
prettyURLs :: Routes
prettyURLs = gsubRoute "[^.]+.html" $ join f
  where f match = case match of
          "index.html" -> id
          _            -> (++"/index.html") . takeWhile (/='.')

-- Bit of a hack
-- $path "/tmp_posts/MyPost.html" is copied into $url
--   and then changed to "posts/MyPost/index.html"
fixURLs :: Compiler (Page String) (Page String)
fixURLs = arr $ changeField "url" f . copyField "path" "url"
          where f = (++"/index.html") . takeWhile (/='.')
                    . ("/posts/"++) . drop 1 . dropWhile (/='/')

-- Title to Pretty final URL component
prettyFilename :: String -> FilePath
prettyFilename = filter (`elem` allowableURLCharacters) . concat . map capitalize . words
  where capitalize (x:xs) = toUpper x : xs


-- "/path/to/my.file" -> ("/path/to/", "my, ".file")
filePathExplode :: FilePath -> (String, String, String)
filePathExplode path = (dir, name, ext)
  where (tmp, dir) = mapTuple reverse $ span (/='/') $ reverse path
        (name, ext) = span (/='.') tmp
        mapTuple f (a1, a2) = (f a1, f a2)

-- Rename files according to $title metadata field
renamePosts = do
  -- Empty temporary directory
  putStrLn "Clearing out temporary posts directory..."
  garbage_files <- getRecursiveContents False tempPostsDirectory
  forM_ garbage_files removeFile
  
  -- And fill up again with new posts
  putStrLn "Determining new post filenames..."
  filenames <- getRecursiveContents False "posts"
  contents <- forM filenames readFile
  let titles = map (getField "title" . readPage) contents
  let new_filenames = map f $ zip filenames titles
              -- Weird Data.Text <-> String translation
              --   and getting around string literal overloading...
        where f = unpack . replace "posts/" (pack tempPostsDirectory) . pack . g
              g (old, title) = if pretty == "" then old else prettified
                where pretty = prettyFilename title
                      prettified = d ++ pretty ++ e
                      (d, n, e) = filePathExplode old
  -- List of necessary changes
  --let changes = filter (\(x,y) -> x /= y) $ zip filenames new_filenames
  let zipped = zip filenames new_filenames
  -- Warn and perform renaming
  forM_ ["Info: Copying blog post: " ++ x ++ " -> " ++ y |
         (x,y)<-zipped] putStrLn
  forM_ zipped (\(old, new) -> copyFile old new)
  putStrLn "Post renaming complete!"

    

addLogItems :: Compiler (Page String, [Page String]) (Page String)
addLogItems = addToPageConcat "logitemsfirst" "templates/postitem.html"
              (take logFirstSize . reverse . chronological)
              &&& arr snd  
              >>> addToPageConcat "logitemsnext" "templates/postitem.html"
              (take logNextSize . drop logFirstSize
               . reverse . chronological)

-- Get a page's key variable and cast into a bool, assuming
--   a default of assume.
getBoolVariable :: String -> Bool -> Page a -> Bool
getBoolVariable key assume p = case assume of
  True  -> not $ val `elem` falsities
  False -> val `elem` truths
  where val = getField key p
        truths = ["True", "true", "T", "t", "Yes", "yes", "Y", "y"]
        falsities = ["False", "false", "F", "f", "No", "no", "N", "n"]



addToPageConcat :: String -> Identifier Template -> ([Page String] -> [Page String])
                     -> Compiler (Page String, [Page String]) (Page String)
addToPageConcat key template selector = setFieldA key $
                                        arr selector
                                        >>> require template
                                        (\p t -> map (applyTemplate t) p)
                                        >>> arr mconcat
                                        >>> arr pageBody
                                        
