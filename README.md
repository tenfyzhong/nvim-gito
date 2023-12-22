# nvim-gito
Open repo in browser

This plugin help you to open the current file/line in browser belong to the repo. 

# install
Use a plugin manager like `lazy.nvim`.
```lua
{
    'tenfyzhong/nvim-gito',
    config = function()
        -- default configuration
        require('gito').setup({
            key = {
                open = '<leader>go',
                copy = '<leader>gy',
            }
        })
    end
}
```

# usage 
## command

| command        | comment                     |
|----------------|-----------------------------|
| `GitoOpen`     | open current file with line |
| `GitoOpenFile` | open current file           |
| `GitoCopy`     | copy current file with line |
|`GitoCopyFile`  | copy current file           |


## default keymap

| mode    | key          | comment    |
|---------|--------------|------------|
| `n` `v` | `<leader>go` | `GitoOpen` |
| `n` `v` | `<leader>gy` | `GitoCopy` |
