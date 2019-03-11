if !has("nvim")
  " Change Font
  if has("gui_win32")
    set guifont=Consolas:h11:cANSI
  endif
  " Remove toolbar
  set guioptions-=T
  " Remove menu
  set guioptions-=m
else
  " Remove tab line
  GuiTabline 0 
  " Remove tab line
  GuiPopupmenu 0 
endif
