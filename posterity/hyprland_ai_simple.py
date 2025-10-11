#!/usr/bin/env python3
"""
Simplified Hyprland AI Controller using hyprctl
This demonstrates how an LLM can control the desktop environment
"""

import subprocess
import json
from typing import Dict, List, Optional, Any

class HyprlandController:
    def __init__(self):
        # Verify Hyprland is running
        try:
            self.run_hyprctl(["version"])
        except Exception as e:
            raise EnvironmentError(f"Hyprland not available: {e}")
    
    def run_hyprctl(self, args: List[str]) -> str:
        """Run hyprctl command and return output"""
        result = subprocess.run(
            ["hyprctl"] + args,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    
    def dispatch(self, cmd: str) -> str:
        """Execute a dispatcher command"""
        return self.run_hyprctl(["dispatch", cmd])
    
    def get_windows(self) -> List[Dict]:
        """Get all windows with their properties"""
        result = self.run_hyprctl(["clients", "-j"])
        return json.loads(result)
    
    def get_workspaces(self) -> List[Dict]:
        """Get all workspaces"""
        result = self.run_hyprctl(["workspaces", "-j"])
        return json.loads(result)
    
    def get_monitors(self) -> List[Dict]:
        """Get monitor information"""
        result = self.run_hyprctl(["monitors", "-j"])
        return json.loads(result)
    
    def get_active_window(self) -> Dict:
        """Get currently focused window"""
        result = self.run_hyprctl(["activewindow", "-j"])
        return json.loads(result)
    
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
            
            if any(x in class_name for x in ['firefox', 'chrome', 'chromium', 'brave']):
                categories['browser'].append(window)
            elif any(x in class_name for x in ['kitty', 'alacritty', 'terminal']):
                categories['terminal'].append(window)
            elif any(x in class_name for x in ['code', 'vim', 'neovim', 'emacs']):
                categories['editor'].append(window)
            elif any(x in class_name for x in ['slack', 'discord', 'teams']):
                categories['communication'].append(window)
            elif any(x in class_name for x in ['mpv', 'vlc', 'spotify']):
                categories['media'].append(window)
            else:
                categories['other'].append(window)
        
        return {
            'categories': {k: len(v) for k, v in categories.items()},
            'windows': {k: [w['title'][:50] for w in v] for k, v in categories.items() if v}
        }
    
    def find_window(self, query: str) -> Optional[Dict]:
        """Find a window by title or class"""
        windows = self.get_windows()
        query_lower = query.lower()
        
        for window in windows:
            if (query_lower in window.get('title', '').lower() or 
                query_lower in window.get('class', '').lower()):
                return window
        return None
    
    def focus_window(self, query: str) -> Dict:
        """Find and focus a window"""
        window = self.find_window(query)
        if window:
            # Focus the window
            self.dispatch(f"focuswindow address:{window['address']}")
            # Switch to its workspace
            workspace_id = window['workspace']['id']
            self.dispatch(f"workspace {workspace_id}")
            return {"success": True, "window": window['title'], "workspace": workspace_id}
        return {"success": False, "error": f"Window '{query}' not found"}
    
    def move_window_to_workspace(self, workspace: int) -> str:
        """Move active window to workspace"""
        return self.dispatch(f"movetoworkspace {workspace}")
    
    def launch_application(self, app: str) -> Dict:
        """Launch an application"""
        # Map common names to commands
        app_map = {
            'browser': 'firefox',
            'terminal': 'kitty',
            'editor': 'code',
            'firefox': 'firefox',
            'chrome': 'google-chrome-stable',
            'kitty': 'kitty',
            'code': 'code',
            'files': 'thunar',
            'music': 'spotify'
        }
        
        command = app_map.get(app.lower(), app)
        self.dispatch(f"exec {command}")
        return {"launched": command}
    
    def get_system_summary(self) -> Dict:
        """Get a summary suitable for LLM consumption"""
        windows = self.get_windows()
        workspaces = self.get_workspaces()
        active = self.get_active_window()
        
        return {
            "active_window": {
                "title": active.get('title', 'None')[:50],
                "class": active.get('class', 'None'),
                "workspace": active.get('workspace', {}).get('id', 0)
            },
            "window_count": len(windows),
            "workspace_count": len(workspaces),
            "workspaces_with_windows": [
                {
                    "id": ws['id'],
                    "name": ws['name'],
                    "windows": ws.get('windows', 0)
                }
                for ws in workspaces if ws.get('windows', 0) > 0
            ],
            "window_categories": self.organize_windows_by_type()['categories']
        }
    
    def execute_command(self, command: str) -> Dict:
        """
        Execute natural language-like commands
        This simulates what an LLM might send
        """
        cmd_lower = command.lower()
        
        # Parse and execute commands
        if "focus" in cmd_lower:
            # Extract target from command
            parts = command.split()
            if len(parts) > 1:
                target = " ".join(parts[1:])
                return self.focus_window(target)
        
        elif "launch" in cmd_lower or "open" in cmd_lower:
            # Extract app name
            parts = command.split()
            if len(parts) > 1:
                app = parts[-1]
                return self.launch_application(app)
        
        elif "workspace" in cmd_lower:
            # Extract workspace number
            for i in range(1, 11):
                if str(i) in command:
                    self.dispatch(f"workspace {i}")
                    return {"switched_to_workspace": i}
        
        elif "organize" in cmd_lower:
            return self.organize_windows_by_type()
        
        elif "close" in cmd_lower:
            self.dispatch("killactive")
            return {"action": "closed_active_window"}
        
        elif "fullscreen" in cmd_lower:
            self.dispatch("fullscreen")
            return {"action": "toggled_fullscreen"}
        
        elif "float" in cmd_lower:
            self.dispatch("togglefloating")
            return {"action": "toggled_floating"}
        
        elif "status" in cmd_lower or "summary" in cmd_lower:
            return self.get_system_summary()
        
        return {"error": f"Unknown command: {command}"}


# Example usage and testing
if __name__ == "__main__":
    import sys
    
    try:
        controller = HyprlandController()
        
        if len(sys.argv) > 1:
            command = " ".join(sys.argv[1:])
            result = controller.execute_command(command)
            print(json.dumps(result, indent=2))
        else:
            # Show example usage
            print("Hyprland AI Controller - Examples")
            print("=" * 40)
            
            # Get system summary
            summary = controller.get_system_summary()
            print("\nSystem Summary:")
            print(json.dumps(summary, indent=2))
            
            print("\n" + "=" * 40)
            print("Example Commands:")
            print("  python hyprland_ai_simple.py status")
            print("  python hyprland_ai_simple.py focus firefox")
            print("  python hyprland_ai_simple.py launch terminal")
            print("  python hyprland_ai_simple.py workspace 3")
            print("  python hyprland_ai_simple.py organize")
            print("  python hyprland_ai_simple.py close")
            
            print("\nThese commands simulate what an LLM agent might send")
            print("to control your desktop environment.")
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)