#!/usr/bin/env python3
"""
Hyprland AI Controller - Bridge between LLMs and Hyprland Window Manager
This demonstrates how an LLM could control the desktop environment
"""

import socket
import json
import os
import subprocess
from typing import Dict, List, Optional, Any
from pathlib import Path

class HyprlandController:
    def __init__(self):
        signature = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
        if not signature:
            raise EnvironmentError("Not running under Hyprland")
        self.socket_path = f"/tmp/hypr/{signature}/.socket.sock"
        self.socket2_path = f"/tmp/hypr/{signature}/.socket2.sock"
    
    def send_command(self, command: str) -> str:
        """Send command to Hyprland via IPC socket"""
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
            sock.connect(self.socket_path)
            sock.sendall(command.encode())
            response = b""
            while True:
                data = sock.recv(4096)
                if not data:
                    break
                response += data
            return response.decode()
    
    def dispatch(self, cmd: str) -> str:
        """Execute a dispatcher command"""
        return self.send_command(f"dispatch {cmd}")
    
    def get_windows(self) -> List[Dict]:
        """Get all windows with their properties"""
        result = self.send_command("j/clients")
        return json.loads(result)
    
    def get_workspaces(self) -> List[Dict]:
        """Get all workspaces"""
        result = self.send_command("j/workspaces")
        return json.loads(result)
    
    def get_monitors(self) -> List[Dict]:
        """Get monitor information"""
        result = self.send_command("j/monitors")
        return json.loads(result)
    
    def get_active_window(self) -> Dict:
        """Get currently focused window"""
        result = self.send_command("j/activewindow")
        return json.loads(result)
    
    # === Window Management Commands ===
    
    def move_window_to_workspace(self, workspace: int) -> str:
        """Move active window to specific workspace"""
        return self.dispatch(f"movetoworkspace {workspace}")
    
    def focus_window(self, address: str) -> str:
        """Focus a specific window by address"""
        return self.dispatch(f"focuswindow address:{address}")
    
    def close_window(self, address: Optional[str] = None) -> str:
        """Close a window (active if no address specified)"""
        if address:
            return self.dispatch(f"closewindow address:{address}")
        return self.dispatch("killactive")
    
    def toggle_floating(self) -> str:
        """Toggle floating for active window"""
        return self.dispatch("togglefloating")
    
    def toggle_fullscreen(self) -> str:
        """Toggle fullscreen for active window"""
        return self.dispatch("fullscreen")
    
    def resize_window(self, x: int, y: int) -> str:
        """Resize active window by delta pixels"""
        return self.dispatch(f"resizeactive {x} {y}")
    
    def move_window(self, x: int, y: int) -> str:
        """Move active window by delta pixels"""
        return self.dispatch(f"moveactive {x} {y}")
    
    # === Workspace Management ===
    
    def switch_workspace(self, workspace: int) -> str:
        """Switch to specific workspace"""
        return self.dispatch(f"workspace {workspace}")
    
    def create_workspace(self, workspace: int) -> str:
        """Create and switch to new workspace"""
        return self.dispatch(f"workspace {workspace}")
    
    # === Layout Management ===
    
    def set_layout(self, layout: str) -> str:
        """Set layout (dwindle or master)"""
        return self.dispatch(f"layoutmsg {layout}")
    
    def toggle_split(self) -> str:
        """Toggle split direction"""
        return self.dispatch("togglesplit")
    
    # === AI-Friendly Commands ===
    
    def organize_windows_by_type(self) -> Dict[str, Any]:
        """Organize windows by application type into workspaces"""
        windows = self.get_windows()
        
        # Categorize windows
        categories = {
            'browser': [],
            'terminal': [],
            'editor': [],
            'communication': [],
            'media': [],
            'other': []
        }
        
        for window in windows:
            class_name = window.get('class', '').lower()
            title = window.get('title', '').lower()
            
            if any(x in class_name for x in ['firefox', 'chrome', 'chromium', 'brave']):
                categories['browser'].append(window)
            elif any(x in class_name for x in ['kitty', 'alacritty', 'terminal', 'konsole']):
                categories['terminal'].append(window)
            elif any(x in class_name for x in ['code', 'vim', 'neovim', 'emacs', 'sublime']):
                categories['editor'].append(window)
            elif any(x in class_name for x in ['slack', 'discord', 'teams', 'telegram']):
                categories['communication'].append(window)
            elif any(x in class_name for x in ['mpv', 'vlc', 'spotify']):
                categories['media'].append(window)
            else:
                categories['other'].append(window)
        
        # Move windows to appropriate workspaces
        workspace_map = {
            'browser': 1,
            'terminal': 2,
            'editor': 3,
            'communication': 4,
            'media': 5,
            'other': 6
        }
        
        results = []
        for category, windows in categories.items():
            if windows:
                workspace = workspace_map[category]
                for window in windows:
                    self.focus_window(window['address'])
                    self.move_window_to_workspace(workspace)
                    results.append({
                        'window': window['title'],
                        'category': category,
                        'workspace': workspace
                    })
        
        return {
            'organized': results,
            'categories': {k: len(v) for k, v in categories.items()}
        }
    
    def create_development_layout(self) -> str:
        """Create a standard development layout on current workspace"""
        # This would arrange windows in a developer-friendly layout
        # For example: editor on left 2/3, terminal on right 1/3
        commands = []
        
        # Get current windows
        windows = self.get_windows()
        active_workspace = self.get_active_window().get('workspace', {}).get('id', 1)
        
        workspace_windows = [w for w in windows if w['workspace']['id'] == active_workspace]
        
        editors = [w for w in workspace_windows if 'code' in w['class'].lower()]
        terminals = [w for w in workspace_windows if 'kitty' in w['class'].lower()]
        
        # Focus and position editor if found
        if editors:
            self.focus_window(editors[0]['address'])
            self.dispatch("layoutmsg preselect l")  # Preselect left
        
        # Focus and position terminal if found
        if terminals:
            self.focus_window(terminals[0]['address'])
            self.dispatch("layoutmsg preselect r")  # Preselect right
        
        return "Development layout applied"
    
    def find_and_focus(self, query: str) -> Optional[Dict]:
        """Find a window by title or class and focus it"""
        windows = self.get_windows()
        query_lower = query.lower()
        
        for window in windows:
            if (query_lower in window.get('title', '').lower() or 
                query_lower in window.get('class', '').lower()):
                self.focus_window(window['address'])
                self.switch_workspace(window['workspace']['id'])
                return window
        
        return None
    
    def launch_application(self, app_command: str) -> str:
        """Launch an application"""
        return self.dispatch(f"exec {app_command}")
    
    def get_system_status(self) -> Dict:
        """Get comprehensive system status for AI analysis"""
        return {
            'windows': self.get_windows(),
            'workspaces': self.get_workspaces(),
            'monitors': self.get_monitors(),
            'active_window': self.get_active_window(),
            'window_count': len(self.get_windows()),
            'active_workspace': self.get_active_window().get('workspace', {}).get('id'),
        }
    
    def execute_ai_instruction(self, instruction: str) -> Dict[str, Any]:
        """
        Parse and execute natural language instructions
        This is a simple example - in practice, you'd use an LLM to parse
        """
        instruction_lower = instruction.lower()
        
        # Simple pattern matching for demonstration
        if "close all" in instruction_lower:
            windows = self.get_windows()
            for window in windows:
                self.close_window(window['address'])
            return {"action": "closed_all_windows", "count": len(windows)}
        
        elif "organize" in instruction_lower:
            return self.organize_windows_by_type()
        
        elif "focus" in instruction_lower:
            # Extract app name (simple approach)
            for word in ['firefox', 'chrome', 'terminal', 'kitty', 'code', 'vscode']:
                if word in instruction_lower:
                    result = self.find_and_focus(word)
                    if result:
                        return {"action": "focused", "window": result['title']}
        
        elif "workspace" in instruction_lower:
            # Extract workspace number
            for i in range(1, 11):
                if str(i) in instruction:
                    self.switch_workspace(i)
                    return {"action": "switched_workspace", "workspace": i}
        
        elif "launch" in instruction_lower or "open" in instruction_lower:
            apps = {
                'browser': 'firefox',
                'terminal': 'kitty',
                'editor': 'code',
                'firefox': 'firefox',
                'chrome': 'google-chrome-stable',
                'kitty': 'kitty',
                'code': 'code'
            }
            
            for app_name, command in apps.items():
                if app_name in instruction_lower:
                    self.launch_application(command)
                    return {"action": "launched", "application": command}
        
        return {"error": "Instruction not understood", "instruction": instruction}


# Example usage for LLM integration
if __name__ == "__main__":
    import sys
    
    controller = HyprlandController()
    
    if len(sys.argv) > 1:
        command = " ".join(sys.argv[1:])
        
        # Handle specific commands
        if command == "status":
            print(json.dumps(controller.get_system_status(), indent=2))
        elif command == "organize":
            result = controller.organize_windows_by_type()
            print(json.dumps(result, indent=2))
        elif command.startswith("focus "):
            query = command[6:]
            window = controller.find_and_focus(query)
            if window:
                print(f"Focused: {window['title']}")
            else:
                print(f"Window not found: {query}")
        elif command.startswith("ai "):
            instruction = command[3:]
            result = controller.execute_ai_instruction(instruction)
            print(json.dumps(result, indent=2))
        else:
            print(f"Unknown command: {command}")
    else:
        print("Hyprland AI Controller")
        print("\nUsage:")
        print("  python hyprland_ai_controller.py status              - Get system status")
        print("  python hyprland_ai_controller.py organize            - Organize windows by type")
        print("  python hyprland_ai_controller.py focus <app>         - Focus a window")
        print("  python hyprland_ai_controller.py ai <instruction>    - Execute AI instruction")
        print("\nExamples:")
        print("  python hyprland_ai_controller.py focus firefox")
        print("  python hyprland_ai_controller.py ai 'open terminal'")
        print("  python hyprland_ai_controller.py ai 'switch to workspace 3'")
        print("  python hyprland_ai_controller.py ai 'organize my windows'")