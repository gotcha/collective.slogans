import random

from zope.component import getUtility

from plone.registry.interfaces import IRegistry

from plone.app.layout.viewlets.common import ViewletBase


class SloganViewlet(ViewletBase):

    @property
    def slogan(self):
        registry = getUtility(IRegistry)
        all_slogans = registry['collective.slogans']
        current_language = self.portal_state.language()
        slogans = [slogan.strip()
                      for slogan
                      in all_slogans.get(current_language, '').splitlines()
                      if slogan.strip()]
        random.shuffle(slogans)
        if slogans:
            return slogans[0]
        else:
            return ''
