# Argos Translate service module for Chaquopy
# Place Argos models (.argosmodel files) into a models directory and call init(path)

installed = False


def init(models_path=None):
    """Initialize Argos Translate environment. Optionally install .argosmodel files
    from the provided models_path directory and load installed packages.
    Returns 'ok' on success or an error string on failure.
    """
    global installed
    try:
        import os
        try:
            import argostranslate.package as package
            import argostranslate.translate as translate
        except Exception:
            # argostranslate may not be installed in the Python env yet
            return 'argostranslate not available'

        if models_path:
            if os.path.isdir(models_path):
                for fname in os.listdir(models_path):
                    if fname.endswith('.argosmodel'):
                        fpath = os.path.join(models_path, fname)
                        try:
                            package.install_from_path(fpath)
                        except Exception as e:
                            # continue installing others but report issue
                            print(f'Failed to install {fpath}: {e}')

        # Load installed packages
        try:
            translate.load_installed_packages()
        except Exception as e:
            print('Warning: could not load installed packages:', e)

        installed = True
        return 'ok'
    except Exception as e:
        return str(e)


def translate(text, src, tgt):
    """Translate text from src to tgt using argostranslate.translate.translate.
    If argostranslate isn't available, returns an error string.
    """
    try:
        import argostranslate.translate as translate_module
    except Exception as e:
        return f'argostranslate not available: {e}'

    try:
        # argostranslate.translate.translate(text, from_code, to_code)
        res = translate_module.translate(text, src, tgt)
        return res
    except Exception as e:
        return f'translation error: {e}'
