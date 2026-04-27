_inputs: _self: super: {
  gh-dash = super.gh-dash.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      # Hide gh-dash branding while preserving tab layout width.
      substituteInPlace internal/tui/constants/constants.go \
        --replace-fail 'Logo = `▜▔▚▐▔▌▚▔▐ ▌' 'Logo = ``' \
        --replace-fail '▟▁▞▐▔▌▁▚▐▔▌`' ""

      substituteInPlace internal/tui/components/tabs/tabs.go \
        --replace-fail 'lipgloss.NewStyle().Foreground(context.LogoColor).Render(constants.Logo),' \
        'lipgloss.NewStyle().Width(11).Render(""),'

      substituteInPlace cmd/root.go \
        --replace-fail 'logo.Render(),' ""

      substituteInPlace internal/tui/components/tabs/testdata/TestTabs/*.golden \
        --replace-fail '▜▔▚▐▔▌▚▔▐ ▌' '           ' \
        --replace-fail '▟▁▞▐▔▌▁▚▐▔▌' '           '

      # Add preview navigation aliases that match the surrounding terminal workflow.
      substituteInPlace internal/tui/keys/keys.go \
        --replace-fail 'key.WithKeys("ctrl+d"),' 'key.WithKeys("ctrl+d", "J", "shift+down"),' \
        --replace-fail 'key.WithHelp("Ctrl+d", "preview page down"),' 'key.WithHelp("Ctrl+d/J/Shift+↓", "preview page down"),' \
        --replace-fail 'key.WithKeys("ctrl+u"),' 'key.WithKeys("ctrl+u", "K", "shift+up"),' \
        --replace-fail 'key.WithHelp("Ctrl+u", "preview page up"),' 'key.WithHelp("Ctrl+u/K/Shift+↑", "preview page up"),' \
        --replace-fail 'key.WithHelp("q", "quit"),' 'key.WithHelp("q/Esc", "quit"),'

      # Make Escape quit except where upstream already uses it to leave notification detail views.
      substituteInPlace internal/tui/ui.go \
        --replace-fail 'case key.Matches(msg, m.keys.Quit):' 'case key.Matches(msg, m.keys.Quit) || (msg.String() == "esc" && (m.ctx.View != config.NotificationsView || (m.notificationView.GetSubjectPR() == nil && m.notificationView.GetSubjectIssue() == nil))):'

      # Use shifted horizontal movement for PR preview tabs.
      substituteInPlace internal/tui/keys/prKeys.go \
        --replace-fail 'key.WithKeys("["),' 'key.WithKeys("[", "H", "shift+left"),' \
        --replace-fail 'key.WithHelp("[", "previous sidebar tab"),' 'key.WithHelp("[/H/Shift+←", "previous sidebar tab"),' \
        --replace-fail 'key.WithKeys("]"),' 'key.WithKeys("]", "L", "shift+right"),' \
        --replace-fail 'key.WithHelp("]", "next sidebar tab"),' 'key.WithHelp("]/L/Shift+→", "next sidebar tab"),'

      # Remove the footer donation prompt.
      substituteInPlace internal/tui/components/footer/footer.go \
        --replace-fail '"github.com/dlvhdr/gh-dash/v4/internal/tui/constants"' "" \
        --replace-fail 'Render(fmt.Sprintf("%s donate", constants.DonateIcon)))' 'Render(""))'
    '';
  });
}
