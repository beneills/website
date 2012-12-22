{-# LANGUAGE OverloadedStrings #-}

-- Import Hakyll library
import Hakyll

-- And Prelude functions
import Control.Arrow ((>>>), (&&&), arr)
import Control.Category (id)
import Control.Monad (join, forM_, forM)
import Data.Char (toUpper)
import Data.Monoid (mconcat, mempty)
import Data.Text (pack, unpack, replace)
import Prelude hiding (id)
import System.Directory (copyFile, removeFile)


-- Paramaters
allowableURLCharacters = ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9']
logFirstSize = 2
logNextSize = 2
tempPostsDirectory = "_posts/"
tempPostsPattern = parseGlob $ tempPostsDirectory++"**"

-- Entry function
main :: IO ()
main = do
  generatePosts
  runHakyll
  

-- Set of rules on how to generate the site
runHakyll :: IO ()
runHakyll = hakyll $ do
    -- CSS (ignore LESS files)
    match "static/css/*.css" $ do
        route   idRoute
        compile compressCssCompiler
    
    -- JavaScript
    match "static/js/*.js" $ do
        route   idRoute
        compile copyFileCompiler

    -- Images
    match "static/images/*" $ do
        route   idRoute
        compile copyFileCompiler
    
    -- HTML templates
    match "templates/*.html" $ compile templateCompiler
        
    -- Compile posts (but do not set a route)
    -- This stops a cyclic dependency (somehow!)
    posts <- group "posts" $ match tempPostsPattern $ do
                  compile $ pageCompiler
                    -- We have to fix URL metadata, since this is used
                    --   when generating the log
                    >>> fixURLsCompiler
                    >>> relativizeUrlsCompiler
    
    -- Applied to (almost) every site page
    -- Adds a user-supplied compiler to the middle of the chain
    let universalCompiler c = requireAllA posts addLogBoxCompiler
                              >>> addCommentsCompiler
                              >>> setLocationCompiler
                              >>> c
                              >>> applyTemplateCompiler "templates/default.html"
                              >>> relativizeUrlsCompiler
    -- Make nice URLs
    let universalRoute = setExtension ".html"
                         `composeRoutes` prettyURLs
    
    -- Site Log
    let logCompiler = arr (setField "title" "Full Log")
                      >>> arr (setField "location" "/log")
                      >>> requireAllA posts addFullLogCompiler
                      >>> applyTemplateCompiler "templates/fulllog.html"
    match "log.html" $ route universalRoute
    create "log.html" $ constA mempty
      >>> universalCompiler logCompiler
    
    -- Pages
    match "pages/**" $ do
        route   $ gsubRoute "pages/" (const "")
          `composeRoutes` universalRoute
        compile $ pageCompiler >>> universalCompiler id
    
    -- Posts
    match tempPostsPattern $ do
        route   $ gsubRoute tempPostsDirectory (const "posts/")  
          `composeRoutes` universalRoute
        compile $ pageCompiler >>> universalCompiler id


    ----Auxillary Compilers

-- Possibly set the page location, if not user-set
setLocationCompiler :: Compiler (Page String) (Page String)
setLocationCompiler = arr $ \x -> trySetField "location" (nice_location x) x
  where nice_location = tryStripSlash
                        . (\ (y,_,_) -> y)
                        . filePathExplode
                        . getField "url"
        tryStripSlash = reverse . dropWhile (=='/') . reverse

-- Possibly add comments based on value of `comments` metadata field
-- Defaults to True
addCommentsCompiler :: Compiler (Page String) (Page String)
addCommentsCompiler = (id &&& applyTemplateCompiler "templates/comments.html"
                       &&& arr (getBoolVariable "comments" True))
                      >>> arr (\(p, (q, c)) -> if c then q else p)

-- Changes the `url` metadata field to reflect our pretty URLs scheme
-- This is necessary for the posts dummy compiler.
-- How it works:
--   $path "/tmp_posts/MyPost.html" is copied into $url
--     and then changed to "posts/MyPost/index.html"
fixURLsCompiler :: Compiler (Page String) (Page String)
fixURLsCompiler = arr $ changeField "url" f . copyField "path" "url"
          where f = (++"/index.html") . takeWhile (/='.')
                    . ("/posts/"++) . drop 1 . dropWhile (/='/')

-- Fills the top-of-page log box with recent items, given
--   a list of posts.
addLogBoxCompiler :: Compiler (Page String, [Page String]) (Page String)
addLogBoxCompiler = addToPageConcat "logitemsfirst" "templates/postitem.html"
              (take logFirstSize . reverse . chronological)
              &&& arr snd  
              >>> addToPageConcat "logitemsnext" "templates/postitem.html"
              (take logNextSize . drop logFirstSize
               . reverse . chronological)

-- Changes `fulllogitems` variable to an HTML rendering of all log items
addFullLogCompiler :: Compiler (Page String, [Page String]) (Page String)
addFullLogCompiler = addToPageConcat "fulllogitems" "templates/postitem.html"
              (reverse . chronological)

-- Generates a compiler that will substitute for variable `key`
--   by concatenating the result of applying `template` to each
--   input page in the list.
addToPageConcat :: String -> Identifier Template
                   -> ([Page String] -> [Page String])
                   -> Compiler (Page String, [Page String]) (Page String)
addToPageConcat key template selector = 
  setFieldA key $
  arr selector
  -- Get rid of index.html rubbish
  >>> arr (map (changeField "url" ((\(x,_,_) -> x) . filePathExplode)))
  >>> require template
  (\p t -> map (applyTemplate t) p)
  >>> arr mconcat
  >>> arr pageBody


    ---- Auxillary Routes

-- Generate nice URLS for pages by putting them in folders
-- We treat the index page as a special case.
prettyURLs :: Routes
prettyURLs = gsubRoute "[^.]+.html" $ join f
  where f match = case match of
          "index.html" -> id
          _            -> (++"/index.html") . takeWhile (/='.')


    ---- Utility Functions

-- Title to pretty final URL component
-- e.g. "My First Post!" -> "MyFirstPost"
prettyFilename :: String -> FilePath
prettyFilename = filter (`elem` allowableURLCharacters) . concat . map capitalize . words
  where capitalize (x:xs) = toUpper x : xs

-- Separate a filepath into its 3 components
-- "/path/to/my.file" -> ("/path/to/", "my, ".file")
filePathExplode :: FilePath -> (String, String, String)
filePathExplode path = (dir, name, ext)
  where (tmp, dir) = mapTuple reverse $ span (/='/') $ reverse path
        (name, ext) = span (/='.') tmp
        mapTuple f (a1, a2) = (f a1, f a2)

-- Get a page's key variable and cast into a bool, assuming
--   a default of assume.
getBoolVariable :: String -> Bool -> Page a -> Bool
getBoolVariable key assume p = case assume of
  True  -> not $ val `elem` falsities
  False -> val `elem` truths
  where val = getField key p
        truths = ["True", "true", "T", "t", "Yes", "yes", "Y", "y"]
        falsities = ["False", "false", "F", "f", "No", "no", "N", "n"]

-- Generate files in `tempPostsDirectory` from files in `posts/`
--   with better names using `prettyFilename`
-- This means we don't have to bother calling the files anything relevant.
generatePosts = do
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
  let zipped = zip filenames new_filenames
  -- Warn and perform renaming
  forM_ ["Info: Copying blog post: " ++ x ++ " -> " ++ y |
         (x,y)<-zipped] putStrLn
  forM_ zipped (\(old, new) -> copyFile old new)
  putStrLn "Post renaming complete!"

    









                                        
