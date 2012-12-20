{-# LANGUAGE OverloadedStrings #-}
import Control.Arrow ((>>>), (***), (&&&), arr, first, second)
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

allowableURLCharacters = ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9']
tempPostsDirectory = "tmp_posts/"
tempPostsPattern = parseGlob $ tempPostsDirectory++"**"


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
                  route   $ setExtension ".html"
                  compile pageCompiler

    -- Pages
    match "pages/**" $ do
        route   $ gsubRoute "pages/" (const "")
          `composeRoutes` setExtension ".html"
          `composeRoutes` prettyURLs
        compile $ pageCompiler
          >>> requireAllA posts addPostList
          >>> applyTemplateCompiler "templates/default.html"
          >>> relativizeUrlsCompiler
    
    
    -- Posts
    match tempPostsPattern $ do
        route   $ setExtension ".html"
          `composeRoutes` gsubRoute tempPostsDirectory (const "posts/")  
          `composeRoutes` prettyURLs
        compile $ pageCompiler
          >>> requireAllA posts addPostList
          >>> applyTemplateCompiler "templates/default.html"
          >>> relativizeUrlsCompiler



-- Applied to (almost) every site page
universalCompiler :: Compiler Resource (Page String)
universalCompiler = pageCompiler
--                    >>> requireAllA tempPostsPattern addLogItems
                    >>>  (arr $ setField "logitemsfirst" "mytest")                    
                    >>> applyTemplateCompiler "templates/default.html"
                    >>> relativizeUrlsCompiler


-- Generate nice URLS for pages by putting them in folders
-- We treat the index page as a special case.
prettyURLs :: Routes
prettyURLs = gsubRoute "[^.]+.html" $ join f
  where f match = case match of
          "index.html" -> id
          _            -> (++"/index.html") . takeWhile (/='.')

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
              (take 2 . reverse . chronological)
              &&& arr snd  
              >>> addToPageConcat "logitemsnext" "templates/postitem.html"
              (drop 2 . reverse . chronological)
  

addToPageConcat :: String -> Identifier Template -> ([Page String] -> [Page String])
                     -> Compiler (Page String, [Page String]) (Page String)
addToPageConcat key template selector = setFieldA key $
                                        arr selector
                                        >>> require template
                                        (\p t -> map (applyTemplate t) p)
                                        >>> arr mconcat
                                        >>> arr pageBody




-- Code to set location string nicely
--          >>> (arr $ trySetField "location" . getField "url")
               -- . getField "url")
--          >>> applyTemplateCompiler "templates/default.html"
--          >>> relativizeUrlsCompiler
--    where f x = trySetField "location" $ nice_location x $ x
--          nice_location x = (\ (x,_,_) -> x)
--                            $ filePathExplode
--                            $ getField "url" x



addPostList :: Compiler (Page String, [Page String]) (Page String)
addPostList = 
  setFieldA "logitemsfirst"
    (mapCompiler (applyTemplateCompiler "templates/mylistingtemplate.html")
     >>> arr mconcat >>> arr pageBody)
