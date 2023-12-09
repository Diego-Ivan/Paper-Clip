public int main (string[] args) {
    Test.init (ref args);
    Test.add_func ("/agent_name/parsing", test_parsing);
    Test.add_func ("/agent-name/fallback", test_fallback);

    return Test.run ();
}

private void test_fallback () {
    var quartz = new AgentName ("macOS Versión 14.0 (Compilación 23A344) Quartz PDFContext");
    with (quartz) {
        assert (organization == "");
        assert (software_name == "macOS Versión 14.0 (Compilación 23A344) Quartz PDFContext");
        assert (version == "");
        assert (tokens == "");
    }

    var mozilla = new AgentName ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 OPR/94.0.0.0 (Edition std-1)");
    with (mozilla) {
        assert (organization == "");
        assert (software_name == "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 OPR/94.0.0.0 (Edition std-1)");
        assert (version == "");
        assert (tokens == "");
    }

    var skia = new AgentName ("Skia/PDF m108");
    with (skia) {
        assert (organization == "");
        assert (software_name == "Skia/PDF m108");
        assert (version == "");
        assert (tokens == "");
    }

    var canva = new AgentName ("Canva");
    with (canva) {
        assert (organization == "");
        assert (software_name == "Canva");
        assert (version == "");
        assert (tokens == "");
    }
}

private void test_parsing () {
    var pdf_library = new AgentName ("Adobe PDF Library 7.0");
    assert (pdf_library.organization == "Adobe");
    assert (pdf_library.software_name == "PDF Library");
    assert (pdf_library.version == "7.0");
    assert (pdf_library.tokens == "");

    var acrobat = new AgentName ("Adobe Acrobat 9.0 (Mac OS X 10.5)");
    assert (acrobat.organization == "Adobe");
    assert (acrobat.software_name == "Acrobat");
    assert (acrobat.version == "9.0");
    assert (acrobat.tokens == "(Mac OS X 10.5)");

    var ghostscript = new AgentName ("GPL Ghostscript 9.26");
    assert (ghostscript.organization == "GPL");
    assert (ghostscript.software_name == "Ghostscript");
    assert (ghostscript.version == "9.26");
    assert (ghostscript.tokens == "");

    var plugin = new AgentName ("Adobe Acrobat 9.55 Paper Capture Plug-in");
    assert (plugin.organization == "Adobe");
    assert (plugin.software_name == "Acrobat");
    assert (plugin.version == "9.55");
    assert (plugin.tokens == "Paper Capture Plug-in");
}
