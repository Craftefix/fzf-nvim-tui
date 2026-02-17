function fn
    function draw_ui
        set_color normal
        echo "╭──────────────────────────────╮"
        echo "│ Selected file:               │"
        echo "│ $selected_file"
        echo "│                              │"
        echo "│ 1 / e - Edit (nvim)          │"
        echo "│ 2 / d - Delete (rm)          │"
        echo "│ 3 / m - Move (rename)        │"
        echo "│                              │"
        echo "│ Press Ctrl+C to quit         │"
        echo "╰──────────────────────────────╯"
    end

    function save_to_history_copy --argument file
        set history_dir ~/.fn
        mkdir -p $history_dir

        if test -f "$file"
            set timestamp (date +%Y%m%d-%H%M%S)
            set base (basename "$file")
            cp "$file" "$history_dir/$timestamp-$base"
        end
    end

    if test (count $argv) -gt 0
        set selected_file $argv[1]
    else
        set selected_file (fzf)
        if test -z "$selected_file"
            echo "No file selected. Exiting."
            return
        end
    end

    save_to_history_copy "$selected_file"

    while true
        clear
        draw_ui
        read -n1 -p "Choice: " choice

        switch $choice
            case 1 e
                clear
                nvim "$selected_file"
                save_to_history_copy "$selected_file"
            case 2 d
                if rm -i "$selected_file"
                    echo "File deleted. Exiting."
                    return
                end
            case 3 m
                echo -n "New name: "
                read new_name
                if test -n "$new_name"
                    set new_path (dirname "$selected_file")/$new_name
                    mv "$selected_file" "$new_path"
                    set selected_file $new_path
                    save_to_history_copy "$selected_file"
                end
            case '*'
                echo "Invalid choice."
        end
    end
end
