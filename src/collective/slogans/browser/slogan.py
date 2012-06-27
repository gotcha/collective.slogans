import random

from Products.CMFCore.utils import getToolByName

from plone.app.layout.viewlets.common import ViewletBase


class SloganViewlet(ViewletBase):

    @property
    def slogan(self):
        result = ''
        if self.slogan_object:
            result = self.slogan_object.Title()
        return result

    @property
    def slogan_url(self):
        result = ''
        if self.slogan_object:
            related = self.slogan_object.getRelatedItems()
            if related:
                result = related[0].absolute_url()
            else:
                url = self.slogan_object.getRemoteUrl()
                if url != 'http://':
                    result = url
        return result

    def update(self):
        super(SloganViewlet, self).update()
        portal = self.portal_state.portal()
        portal_catalog = getToolByName(portal, 'portal_catalog')
        all_slogans = [slogan for slogan in portal_catalog(portal_type='Slogan')]
        if all_slogans:

            random.shuffle(all_slogans)
            self.slogan_object = all_slogans[0].getObject()
        else:
            self.slogan_object = None
