" ============================================================================
" vim-howdoi
" Description: vim howdoi plugin
" Maintainer:  Laurent Goudet <me at laurentgoudet dot com>
" Version:     1.0
" Last Change: Fri Dec 27 09:39:42 EST 2013
" License:     WTFPL (Do What the Fuck You Want to Public License) v2
" ============================================================================

" Section: Script init {{{1
" ===========================================================================

" Allow the user to disable the plugin & prevent multiple loads
if exists("g:howdoi")
    finish
endif

if !exists('g:howdoi_map') | let g:howdoi_map = '<c-h>' | en

if !has('python')
  echoerr "Required vim compiled with +python"
    finish
endif

let g:howdoi = 1

" Section: Functions definitions {{{1
" ===========================================================================

function! s:Howdoi()

python << EOF

import subprocess, vim

howdoi_installed = vim.eval("executable('howdoi')")
if howdoi_installed == "0":
  print "Expected howdoi package to be installed"

filetypes = {
  "c" : "c",
  "java" : "java",
  "cpp" : "c++",
  "cs" : "c#",
  "python" : "python",
  "php" : "php",
  "javascript" : "javascript",
  "ruby" : "ruby"
}

query = vim.current.line
filetype = vim.eval("&ft")

# add filetype to query if not already present
if filetype in filetypes:
  if filetype not in query:
    query += " in " + filetypes[filetype]

# Call howdoi, I'm way too lazy
p = subprocess.Popen("howdoi " + query,
  stdout=subprocess.PIPE,
  stderr=subprocess.PIPE,
  shell=True)
output, errors = p.communicate()

# Clean up a bit
lines = filter(None, output.replace('\r', '').split('\n'))

# Renove the query line
del vim.current.line

# Append the result at the cursor's position
vim.current.range.append(lines, 0)

# Indent it
vim.command("normal! " + str(len(lines)) + "==" )

EOF
endfunction


" Section: Create mapping & menu items {{{1
" ===========================================================================

" Create menu items for the specified modes.  If a:combo is not empty, then
" also define mappings and show a:combo in the menu items.
" Thanks NERDCommenter plugin
function! s:CreateMaps(target, desc, combo)

  "Internal mapping
  let plug = '<Plug>' . a:target
  execute 'noremap <unique> <script> ' . plug . ' :call <SID>' . a:target . '()<CR>'

  " Setup default combo
  if strlen(a:combo) && !exists("no_plugin_maps")
    if !hasmapto(plug)
      execute 'map ' . a:combo . ' ' . plug
    endif
  endif

  " Menu entry
  let menu_command = 'amenu <silent>' . '&Plugin.howdoi' . '.' . escape(a:desc, ' ')
  if strlen(a:combo)
    let menu_command .= '<Tab>' . a:combo . ' ' . plug
  else
    " Separator
    let menu_command .= ' :'
  endif
  execute menu_command

endfunction

" Function name / Menu entry / Default mapping
call s:CreateMaps('Howdoi', 'howdoi', g:howdoi_map)

