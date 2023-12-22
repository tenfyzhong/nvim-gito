local M = {}

local function formatRemote(remote)
    if remote == '' then
        return ''
    end
    remote = string.gsub(remote, '^ssh://git@([^/]+)', 'https://%1', 1)
    remote = string.gsub(remote, '^git@([^/:]+):', 'https://%1/', 1)
    remote = string.gsub(remote, '%.git$', '', 1)
    return remote
end

local function lineDelim(host)
    if string.find(host, 'github.com') ~= nil then
        return '-L'
    elseif string.find(host, 'bitbucket.org') ~= nil then
        return ':'
    else
        return '-'
    end
end

local function lineParam(host, line1, line2)
    if line1 == 0 then
        return ''
    end
    if line2 == 0 or line1 == line2 then
        return string.format('#L%d', line1)
    end
    if host == '' then
        return ''
    end
    local delim = lineDelim(host)
    return string.format('#L%d%s%d', line1, delim, line2)
end

local function gitoUrl(line1, line2)
    line1 = line1 or 0
    line2 = line2 or 0

    local gitdir = vim.fn.system({ 'git', 'rev-parse', '--git-dir' })
    gitdir = string.gsub(gitdir, '%s*$', '')
    if gitdir == '' then
        return ''
    end

    local branch = vim.fn.system({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' })
    branch = string.gsub(branch, '%s*$', '')
    if branch == '' then
        return ''
    end

    local remote_name = vim.fn.system({ 'git', 'config', '--get', string.format('branch.%s.remote', branch) })
    remote_name = string.gsub(remote_name, '%s*$', '')
    if remote_name == '' then
        return ''
    end

    local remote = vim.fn.system({ 'git', 'remote', 'get-url', remote_name })
    remote = string.gsub(remote, '%s*$', '')
    if remote == '' then
        return ''
    end
    remote = formatRemote(remote)

    local filename = vim.fn.expand('%')

    local path = vim.fn.system({ 'realpath', filename })
    path = string.gsub(path, '%s*$', '')
    local gitroot = vim.fn.system({ 'git', 'rev-parse', '--show-toplevel' })
    gitroot = string.gsub(gitroot, '%s*$', '')
    local rootlen = string.len(gitroot)
    local realtive = string.sub(path, rootlen + 1)

    if line1 > line2 then
        line1, line2 = line2, line1
    end
    local line = lineParam(remote, line1, line2)
    local url = string.format('%s/tree/%s%s%s', remote, branch, realtive, line)
    url = string.gsub(url, '%s*$', '')
    return url
end

local function gitoOpenLine(opts)
    opts = opts or {}
    local line1 = opts.line1
    local line2 = opts.line2
    local mode = vim.fn.mode()
    if mode == 'v' or mode == 'V' then
        line1 = vim.fn.getpos("'<")[1]
        line2 = vim.fn.getpos("'>")[1]
    end
    local url = gitoUrl(line1, line2)
    print(url)
    if vim.fn.executable('xdg-open') == 1 then
        vim.fn.system({ 'xdg-open', url })
    elseif vim.fn.executable('open') == 1 then
        vim.fn.system({ 'open', url })
    else
        print('Gito: no `open` or equivalent command found')
    end
end

local function gitOpenFile(opts)
    opts = opts or {}
    local url = gitoUrl(0, 0)
    print(url)
    if vim.fn.executable('xdg-open') == 1 then
        vim.fn.system({ 'xdg-open', url })
    elseif vim.fn.executable('open') == 1 then
        vim.fn.system({ 'open', url })
    else
        print('Gito: no `open` or equivalent command found')
    end
end

local function gitoCopyLine(opts)
    opts = opts or {}
    local line1 = opts.line1
    local line2 = opts.line2
    local url = gitoUrl(line1, line2)
    print(url)
    vim.fn.setreg('+', url)
end

local function gitoCopyFile(opts)
    opts = opts or {}
    local url = gitoUrl(0, 0)
    print(url)
    vim.fn.setreg('+', url)
end

function M.setup(opt)
    opt = opt or {}
    vim.api.nvim_create_user_command('GitoOpen', gitoOpenLine, {
        desc = 'Open current line in browser',
        force = true,
        range = true,
    })
    vim.api.nvim_create_user_command('GitoOpenFile', gitOpenFile, {
        desc = 'Open current file in browser',
        force = true,
        range = true,
    })
    vim.api.nvim_create_user_command('GitoCopy', gitoCopyLine, {
        desc = 'Open current file in browser',
        force = true,
        range = true,
    })
    vim.api.nvim_create_user_command('GitoCopyFile', gitoCopyFile, {
        desc = 'Open current file in browser',
        force = true,
        range = true,
    })

    local key = opt.key or {}
    local open_key = key.open or '<leader>go'
    local copy_key = key.open or '<leader>gy'
    vim.keymap.set({ 'n' }, open_key, ':GitoOpen<cr>',
        { silent = true, remap = false, desc = 'open current line in browser' })
    vim.keymap.set({ 'n' }, copy_key, ':GitoCopy<cr>',
        { silent = true, remap = false, desc = 'copy current line in browser' })
    vim.keymap.set({ 'v' }, open_key, ":'<,'>GitoOpen<cr>",
        { silent = true, remap = false, desc = 'open current line in browser' })
    vim.keymap.set({ 'v' }, copy_key, ":'<,'>GitoCopy<cr>",
        { silent = true, remap = false, desc = 'copy current line in browser' })
end

return M
