" Vim Pastebin for my work's CodeTrunk install
" Use this or not, I don't really care
" To setup, either define your codetrunk's URL in your vimrc file:
"    let g:pastebin='http://paste.example.com/'
" or in your ~/.bash_profile:
"    export PASTEBIN='http://paste.example.com/'

" Make sure the Vim was compiled with +python before loading the script...
if !has("python")
        finish
endif

if !exists("g:pastebin")
    let g:pastebin=''
endif

if !exists("g:pastebin_user")
    let g:pastebin_user="vim plugin"
endif

:vmap <leader>p :PasteCode<cr>

:command! -range             PasteCode :py PasteMe(<line1>,<line2>)
:command! -range             PasteCodeM :py PasteMe(<line1>,<line2>, length='m')
:command! -range             PasteCodeF :py PasteMe(<line1>,<line2>, length='f')
:command!                    PasteFile :py PasteMe()
:command!                    PasteFileM :py PasteMe(length='m')
:command!                    PasteFileF :py PasteMe(length='f')

python << EOF
import vim
try:
    import mechanize
except:
    pass

def PasteMe(start=-1, end=-1, length='d'):
    # Get pastebin address
    pastebin = vim.eval("g:pastebin")
    if pastebin == '' and os.environ.has_key('PASTEBIN'):
        pastebin = os.environ['PASTEBIN']
    else:
        print 'You need to define a codetrunk pastbin address'

    # Get username
    user = vim.eval("g:pastebin_user")
    # Set time to keep
    time_to_keep = ['%s' % length]


    # Init mechanize stuff...
    br = mechanize.Browser()
    br.set_handle_robots(False)
    br.open(pastebin)
    # Get form
    for item in br.forms():
        if item.action.split('/')[-1] == 'submitTrunk':
            form = item

    # Set language type
    format = vim.eval('&ft')
    if format == 'python':
        format = ['py']
    elif format == 'javascript':
        format = ['js']
    elif format == 'html':
        format = ['html']
    elif format == 'css':
        format = ['css']
    elif format == 'diff':
        format = ['diff']
    elif format == 'sh':
        format = ['bash']
    elif format == 'perl':
        format = ['perl']
    elif format == 'xml':
        format = ['xml']
    elif format == 'php':
        format = ['php']
    elif format == 'cpp':
        format = ['cpp']
    elif format == 'java':
        format = ['java']
    elif format == 'erlang':
        format = ['erlang']
    elif format == 'ruby':
        format = ['ruby']
    elif format == 'sql':
        format = ['sql']
    elif format == 'groovy':
        format = ['groovy']
    elif format == 'lua':
        format = ['lua']
    elif format == 'scala':
        format = ['scala']
    elif format == 'vb':
        format = ['vb']
# I don't care enough to look up the following
#    elif format == '':
#        format = ['csharp']
#    elif format == '':
#        format = ['as3']
#    elif format == '':
#        format = ['coldf']
#    elif format == '':
#        format = ['delphi']
#    elif format == '':
#        format = ['jfx']
#    elif format == '':
#        format = ['ps'] # Powershell, not postscript
    else:
        format = ['text']
    form['ctSyntaxLanguage'] = format

    if start != -1 and end !=-1:
        code = '\n'.join(vim.current.buffer[int(start)-1:int(end)])
    else:
        code = '\n'.join(vim.current.buffer[:])

    form['ctTrunk'] = code

    form['ctName'] = user

    form['ctExpiry'] = time_to_keep

    req = form.click(type="submit", nr=0)
    response = br.open(req)
    print 'Pasted: %s' % response.geturl()

EOF
