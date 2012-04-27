from plone.app.testing import PloneWithPackageLayer
from plone.app.testing import IntegrationTesting
from plone.app.testing import FunctionalTesting

import collective.slogans


COLLECTIVE_SLOGANS = PloneWithPackageLayer(zcml_package=collective.slogans,
    zcml_filename='configure.zcml',
    gs_profile_id='collective.slogans:default', name='COLLECTIVE_SLOGANS')

COLLECTIVE_SLOGANS_INTEGRATION = IntegrationTesting(
        bases=(COLLECTIVE_SLOGANS, ), name="COLLECTIVE_SLOGANS_INTEGRATION")

COLLECTIVE_SLOGANS_FUNCTIONAL = FunctionalTesting(
        bases=(COLLECTIVE_SLOGANS, ), name="COLLECTIVE_SLOGANS_FUNCTIONAL")
