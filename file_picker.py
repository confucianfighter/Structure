from textual.app import App, ComposeResult
from textual.widgets import Tree, Log
from textual.containers import Horizontal
from textual import events
import os


class FileTree(Tree):
    BINDINGS = [
        ("space", "toggle_select", "Toggle selection"),
        ("shift+space", "select_range", "Select range"),
        # Removed the 'enter' binding since we'll handle it directly
    ]

    def __init__(self, label, **kwargs):
        super().__init__(label, **kwargs)
        self.selected_files = set()
        self.last_selected_node = None

    async def key_enter(self, event: events.Key) -> None:
        """
        Handles the Enter key to expand or collapse a folder.
        """
        event.stop()
        await self.action_toggle_expand()

    async def action_toggle_select(self) -> None:
        """
        Toggle selection of the currently focused node.
        """
        node = self.cursor_node
        if node and node.data and node.data.get("type") == "file":
            file_path = node.data["path"]
            if file_path in self.selected_files:
                self.selected_files.remove(file_path)
            else:
                self.selected_files.add(file_path)
            self.update_node_label(node)
            self.last_selected_node = node

    async def action_select_range(self) -> None:
        """
        Selects a range of files from the last selected node to the current cursor node.
        """
        node = self.cursor_node
        if not self.last_selected_node:
            await self.action_toggle_select()
            return

        all_file_nodes = self.get_all_file_nodes()
        try:
            index1 = all_file_nodes.index(self.last_selected_node)
            index2 = all_file_nodes.index(node)
        except ValueError:
            return

        start = min(index1, index2)
        end = max(index1, index2)

        for node in all_file_nodes[start:end+1]:
            file_path = node.data["path"]
            if file_path not in self.selected_files:
                self.selected_files.add(file_path)
                self.update_node_label(node)

        self.last_selected_node = node

    async def action_toggle_expand(self) -> None:
        """
        Expands or collapses the currently focused folder.
        """
        node = self.cursor_node
        if node and node.data and node.data.get("type") == "folder":
            if node.is_expanded:
                node.collapse()
            else:
                node.expand()

    def get_all_file_nodes(self):
        """
        Retrieves all file nodes in the tree in display order.
        """
        nodes = []

        def collect_nodes(node):
            for child in node.children:
                if child.data and child.data.get("type") == "file":
                    nodes.append(child)
                collect_nodes(child)

        collect_nodes(self.root)
        return nodes

    def update_node_label(self, node):
        """
        Updates the label of a single node to reflect its selection state.
        """
        if node.data and node.data.get("type") == "file":
            file_path = node.data["path"]
            base_name = os.path.basename(file_path)
            if file_path in self.selected_files:
                node.set_label(f"[bold green]{base_name}[/bold green]")
            else:
                node.set_label(base_name)


class FileTreeSelectorApp(App):
    CSS = """
    #file_tree {
        border: round green;
        width: 1fr;
        height: 100%;
    }
    #log_panel {
        border: round yellow;
        width: 40%;
        height: 100%;
    }
    """

    # Define key bindings at the App level
    BINDINGS = [
        ("s", "show_selected", "Show selected files"),
    ]

    def compose(self) -> ComposeResult:
        self.file_tree = FileTree("File System", id="file_tree")
        self.build_tree(self.file_tree.root, ".")
        self.file_tree.root.collapse()

        self.log_panel = Log(id="log_panel")

        # Use Horizontal container to layout the widgets side by side
        yield Horizontal(
            self.file_tree,
            self.log_panel,
        )

    def build_tree(self, parent_node, path):
        """
        Recursively builds the file tree structure.
        """
        try:
            for item in sorted(os.listdir(path)):
                item_path = os.path.join(path, item)
                if os.path.isdir(item_path):
                    # Add a branch for directories
                    folder_node = parent_node.add(
                        item,
                        data={"path": item_path, "type": "folder"},
                    )
                    folder_node.allow_expand = True
                    folder_node.collapse()  # Start folders collapsed
                    self.build_tree(folder_node, item_path)
                else:
                    # Add a leaf for files
                    parent_node.add_leaf(
                        item,
                        data={"path": item_path, "type": "file"},
                    )
        except PermissionError:
            parent_node.add_leaf(
                "[Permission Denied]",
                data={"path": None, "type": "error"},
            )

    async def action_show_selected(self) -> None:
        """
        Displays the currently selected files in the log panel.
        """
        self.log_panel.clear()
        selected_files = self.file_tree.selected_files
        if selected_files:
            self.log_panel.write("[bold green]Selected files:[/bold green]")
            for file in sorted(selected_files):
                self.log_panel.write(f"  - {file}")
        else:
            self.log_panel.write("[bold red]No files selected.[/bold red]")


if __name__ == "__main__":
    app = FileTreeSelectorApp()
    app.run()
