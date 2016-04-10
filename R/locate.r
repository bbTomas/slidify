#' Locate the position of the first occurence of a pattern in a string.
#'
#' Vectorised over \code{string} and \code{pattern}, shorter is recycled to
#' same length as longest.
#'
#' @inheritParams str_detect
#' @return integer matrix.  First column gives start postion of match, and
#'   second column gives end position.
#' @keywords character
#' @seealso
#'   \code{\link{regexpr}} which this function wraps
#'
#'   \code{\link{str_extract}} for a convenient way of extracting matches
#
#'   \code{\link{str_locate_all}} to locate position of all matches
#'
#' @export
#' @examples
#' fruit <- c("apple", "banana", "pear", "pinapple")
#' str_locate(fruit, "a")
#' str_locate(fruit, "e")
#' str_locate(fruit, c("a", "b", "p", "p"))
str_locate <- function(string, pattern) {
  string <- check_string(string)
  pattern <- check_pattern(pattern, string)

  if (length(pattern) == 1) {
    results <- re_call("regexpr", string, pattern)
    match_to_matrix(results)
  } else {
    results <- re_mapply("regexpr", string, pattern)
    out <- t(vapply(results, match_to_matrix, integer(2)))
    colnames(out) <- c("start", "end")
    out
  }
}

#' Locate the position of all occurences of a pattern in a string.
#'
#' Vectorised over \code{string} and \code{pattern}, shorter is recycled to
#' same length as longest.
#'
#' If the match is of length 0, (e.g. from a special match like \code{$})
#' end will be one character less than start.
#'
#' @inheritParams str_detect
#' @keywords character
#' @return list of integer matrices.  First column gives start postion of
#'   match, and second column gives end position.
#' @seealso
#'  \code{\link{regexpr}} which this function wraps
#'
#'  \code{\link{str_extract}} for a convenient way of extracting matches
#'
#'  \code{\link{str_locate}} to locate position of first match
#'
#' @export
#' @examples
#' fruit <- c("apple", "banana", "pear", "pineapple")
#' str_locate_all(fruit, "a")
#' str_locate_all(fruit, "e")
#' str_locate_all(fruit, c("a", "b", "p", "p"))
str_locate_all <- function(string, pattern) {
  string <- check_string(string)
  pattern <- check_pattern(pattern, string)

  if (length(pattern) == 1) {
    matches <- re_call("gregexpr", string, pattern)
  } else {
    matches <- unlist(re_mapply("gregexpr", string, pattern),
      recursive = FALSE)
  }
  lapply(matches, match_to_matrix, global = TRUE)
}

# Convert annoying regexpr format to something more useful
match_to_matrix <- function(match, global = FALSE) {
  if (global && length(match) == 1 && (is.na(match) || match == -1)) {
    null <- matrix(0, nrow = 0, ncol = 2)
    colnames(null) <- c("start", "end")

    return(null)
  }

  start <- as.vector(match)
  start[start == -1] <- NA
  end <- start + attr(match, "match.length") - 1L

  cbind(start = start, end = end)
}


#' Switch location of matches to location of non-matches.
#'
#' Invert a matrix of match locations to match the opposite of what was
#' previously matched.
#'
#' @param loc matrix of match locations, as from \code{\link{str_locate_all}}
#' @return numeric match giving locations of non-matches
#' @export
#' @examples
#' numbers <- "1 and 2 and 4 and 456"
#' num_loc <- str_locate_all(numbers, "[0-9]+")[[1]]
#' str_sub(numbers, num_loc[, "start"], num_loc[, "end"])
#'
#' text_loc <- invert_match(num_loc)
#' str_sub(numbers, text_loc[, "start"], text_loc[, "end"])
invert_match <- function(loc) {
  cbind(
    start = c(0L, loc[, "end"] + 1L),
    end = c(loc[, "start"] - 1L, -1L)
  )
}
