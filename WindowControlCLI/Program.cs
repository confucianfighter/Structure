using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

namespace WindowControlCLI
{
    class Program
    {
        // Constants for window style manipulation
        private const int GWL_STYLE = -16;                
        private const int WS_OVERLAPPEDWINDOW = 0x00CF0000;
        private const int WS_POPUP = unchecked((int)0x80000000);

        // ShowWindow commands
        private const int SW_MINIMIZE = 6;
        private const int SW_RESTORE = 9;

        // Flags for SetWindowPos
        private static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
        private static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
        private const uint SWP_NOSIZE = 0x0001;
        private const uint SWP_NOMOVE = 0x0002;
        private const uint SWP_NOZORDER = 0x0004;
        private const uint SWP_FRAMECHANGED = 0x0020;
        private const uint SWP_SHOWWINDOW = 0x0040;
        private const uint SWP_NOOWNERZORDER = 0x0200;

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern int GetWindowTextLength(IntPtr hWnd);

        [DllImport("user32.dll")]
        private static extern bool IsWindowVisible(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern int GetWindowLong(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool SetWindowPos(
            IntPtr hWnd,
            IntPtr hWndInsertAfter,
            int X,
            int Y,
            int cx,
            int cy,
            uint uFlags
        );

        // For enumerating windows
        private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

        [DllImport("user32.dll")]
        private static extern int GetSystemMetrics(int nIndex);

        static void Main(string[] args)
        {
            if (args.Length < 2)
            {
                PrintUsage();
                return;
            }

            // First arg = partial window title, second arg = command
            var searchTerm = args[0];
            var command = args[1].ToLowerInvariant();

            // Find all matching windows (case-insensitive, partial match)
            var matches = FindWindowsByTitle(searchTerm);
            if (matches.Count == 0)
            {
                Console.WriteLine($"No windows found matching '{searchTerm}'.");
                return;
            }

            // Handle the first matching window for this example
            IntPtr targetHWnd = matches[0];
            Console.WriteLine($"Found window handle: 0x{targetHWnd.ToInt64():X} for partial title '{searchTerm}'");

            switch (command)
            {
                case "always_on_top":
                    SetAlwaysOnTop(targetHWnd, true);
                    break;
                case "remove_always_on_top":
                    SetAlwaysOnTop(targetHWnd, false);
                    break;
                case "minimize":
                    ShowWindow(targetHWnd, SW_MINIMIZE);
                    break;
                case "restore":
                    ShowWindow(targetHWnd, SW_RESTORE);
                    break;
                case "fullscreen":
                    SetFullscreen(targetHWnd, true);
                    break;
                case "normal":
                    SetFullscreen(targetHWnd, false);
                    break;
                case "isfullscreen":
                    bool isFS = IsWindowFullscreen(targetHWnd);
                    Console.WriteLine($"Is fullscreen? {isFS}");
                    break;
                default:
                    Console.WriteLine($"Unknown command '{command}'.");
                    PrintUsage();
                    break;
            }
        }

        // Toggle always-on-top by using SetWindowPos with HWND_TOPMOST or HWND_NOTOPMOST
        static void SetAlwaysOnTop(IntPtr hWnd, bool enable)
        {
            SetWindowPos(
                hWnd,
                enable ? HWND_TOPMOST : HWND_NOTOPMOST,
                0, 0, 0, 0,
                SWP_NOMOVE | SWP_NOSIZE
            );
        }

        // Minimal approach to toggling fullscreen:
        // Remove WS_OVERLAPPEDWINDOW => use WS_POPUP
        // OR revert to WS_OVERLAPPEDWINDOW
        static void SetFullscreen(IntPtr hWnd, bool enable)
        {
            int style = GetWindowLong(hWnd, GWL_STYLE);

            if (enable)
            {
                // Switch to WS_POPUP
                style &= ~WS_OVERLAPPEDWINDOW;
                style |= WS_POPUP;
                SetWindowLong(hWnd, GWL_STYLE, style);

                // Expand to cover entire primary display
                var screenWidth = GetSystemMetrics(0);  // SM_CXSCREEN
                var screenHeight = GetSystemMetrics(1); // SM_CYSCREEN

                SetWindowPos(
                    hWnd,
                    IntPtr.Zero,
                    0,
                    0,
                    screenWidth,
                    screenHeight,
                    SWP_NOZORDER | SWP_FRAMECHANGED | SWP_SHOWWINDOW
                );
            }
            else
            {
                // Restore normal window
                style &= ~WS_POPUP;
                style |= WS_OVERLAPPEDWINDOW;
                SetWindowLong(hWnd, GWL_STYLE, style);

                // Hard-coded size/pos (you may want to store & restore real size)
                SetWindowPos(
                    hWnd,
                    IntPtr.Zero,
                    100,
                    100,
                    1280,
                    720,
                    SWP_NOZORDER | SWP_FRAMECHANGED | SWP_SHOWWINDOW
                );
            }
        }

        /// <summary>
        /// Returns whether the window is in "fullscreen" mode by checking if
        /// we removed WS_OVERLAPPEDWINDOW and added WS_POPUP.
        /// </summary>
        static bool IsWindowFullscreen(IntPtr hWnd)
        {
            int style = GetWindowLong(hWnd, GWL_STYLE);

            // Minimal check: if we have WS_POPUP and do not have WS_OVERLAPPEDWINDOW,
            // we consider it "fullscreen" by our code's definition
            bool hasPopup = (style & WS_POPUP) != 0;
            bool hasOverlapped = (style & WS_OVERLAPPEDWINDOW) != 0;

            return (hasPopup && !hasOverlapped);
        }

        // Use the WinAPI to enumerate windows and look for partial matches
        static List<IntPtr> FindWindowsByTitle(string partialTitle)
        {
            var results = new List<IntPtr>();
            var searchLower = partialTitle.ToLowerInvariant();

            EnumWindows((hWnd, lParam) =>
            {
                if (!IsWindowVisible(hWnd))
                    return true;  // Skip invisible

                int length = GetWindowTextLength(hWnd);
                if (length == 0)
                    return true; // Skip if no title

                var sb = new StringBuilder(length + 1);
                GetWindowText(hWnd, sb, sb.Capacity);
                var windowTitle = sb.ToString().ToLowerInvariant();

                if (windowTitle.Contains(searchLower))
                {
                    results.Add(hWnd);
                }

                return true; // continue enumerating
            }, IntPtr.Zero);

            return results;
        }

        // Simple usage display
        static void PrintUsage()
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("  WindowControlCLI.exe <PartialTitle> <Command>");
            Console.WriteLine();
            Console.WriteLine("Commands:");
            Console.WriteLine("  always_on_top         - Make the window always on top");
            Console.WriteLine("  remove_always_on_top  - Remove always-on-top");
            Console.WriteLine("  minimize              - Minimize the window");
            Console.WriteLine("  restore               - Restore the window");
            Console.WriteLine("  fullscreen            - Make the window fullscreen (popup style)");
            Console.WriteLine("  normal                - Restore the window to normal style");
            Console.WriteLine("  isFullscreen          - Check if the window is currently fullscreen");
        }
    }
}
