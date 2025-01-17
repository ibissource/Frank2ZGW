<xsl:stylesheet exclude-result-prefixes="#all" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

    <xsl:param name="MatchWithZgwRol" as="node()"><xsl:document /></xsl:param>

    <xsl:param name="debug" as="xs:string" select="'false'" />
	<xsl:variable name="debugSerializeParams" as="map(xs:string, item()?)">
		<xsl:map>
			<xsl:map-entry key="'indent'" select="true()"/>
		</xsl:map>
	</xsl:variable>

    <xsl:variable name="rootName" select="local-name($MatchWithZgwRol/*)" />

    <xsl:template match="/">
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> MatchWithZgwRol: [{serialize($MatchWithZgwRol, $debugSerializeParams)}] </xsl:comment></xsl:if>
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> rootName: [{serialize($rootName, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <roles>
            <xsl:variable name="matchingRoles">
                <xsl:apply-templates select="//*[local-name() = $rootName]"/>
            </xsl:variable>
            <xsl:copy-of select="$matchingRoles//namespace-node()" />
            <!-- Transfer any namespaces from children to roles parent -->
            <xsl:copy-of select="$matchingRoles" copy-namespaces="false" />
        </roles>
    </xsl:template>

    <xsl:template match="*:zgwRol">
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> rolesTemplateInput: [{serialize(., $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> rootName: [{serialize(*[*:betrokkeneType = $MatchWithZgwRol/*:betrokkeneType], $debugSerializeParams)}] </xsl:comment></xsl:if>
        <xsl:apply-templates select="*[*:betrokkeneType = $MatchWithZgwRol/*/*:betrokkeneType and *:omschrijving = $MatchWithZgwRol/*/*:omschrijving]" />
    </xsl:template>

    <!-- NNP-zkn-kerngegevensKennisgeving -->
    <xsl:template match="*[*:betrokkeneType = 'niet_natuurlijk_persoon' and *:omschrijving = $MatchWithZgwRol/*/*:omschrijving]">
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> betrokkeneIdentificatieTemplateInput: [{serialize(., $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="matchWithZgwRolBetrokkeneIdentificatie" select="$MatchWithZgwRol/*/*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> matchWithZgwRolBetrokkeneIdentificatie: [{serialize($matchWithZgwRolBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="currentBetrokkeneIdentificatie" select="*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> currentBetrokkeneIdentificatie: [{serialize($currentBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:choose>
            <xsl:when test="$currentBetrokkeneIdentificatie/*:innNnpId/text() != '' and $matchWithZgwRolBetrokkeneIdentificatie/*:innNnpId/text() != ''">
                <xsl:if test="$currentBetrokkeneIdentificatie/*:innNnpId/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:innNnpId/text()">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:when>
            <xsl:when test="$currentBetrokkeneIdentificatie/*:annIdentificatie/text() != '' and $matchWithZgwRolBetrokkeneIdentificatie/*:annIdentificatie/text() != ''">
                <xsl:if test="$currentBetrokkeneIdentificatie/*:annIdentificatie/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:annIdentificatie/text()">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:when>
            <!-- The test checks if all of the elements have the same value on both sides as a whole AND checks if atleast 1 of them is not empty.
                OR statements between () is to prevent positively matching on the absence of all elements on both sides. -->
            <xsl:when test="
                ($currentBetrokkeneIdentificatie/*:statutaireNaam/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:statutaireNaam/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:statutaireNaam)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:statutaireNaam)))) and
                ($currentBetrokkeneIdentificatie/*:innRechtsvorm/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:innRechtsvorm/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:innRechtsvorm)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:innRechtsvorm)))) and
                ($currentBetrokkeneIdentificatie/*:statutaireNaam/text() != '' or 
                $currentBetrokkeneIdentificatie/*:innRechtsvorm/text() != '')
                ">
                <xsl:copy-of select="." />
            </xsl:when>
            <xsl:otherwise />
        </xsl:choose>
    </xsl:template>

    <!-- NPS-zkn-kerngegevensKennisgeving -->
    <xsl:template match="*[*:betrokkeneType = 'natuurlijk_persoon' and *:omschrijving = $MatchWithZgwRol/*/*:omschrijving]">
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> betrokkeneIdentificatieTemplateInput: [{serialize(., $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="matchWithZgwRolBetrokkeneIdentificatie" select="$MatchWithZgwRol/*/*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> matchWithZgwRolBetrokkeneIdentificatie: [{serialize($matchWithZgwRolBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="currentBetrokkeneIdentificatie" select="*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> currentBetrokkeneIdentificatie: [{serialize($currentBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:choose>
            <xsl:when test="$currentBetrokkeneIdentificatie/*:inpBsn/text() != '' and $matchWithZgwRolBetrokkeneIdentificatie/*:inpBsn/text() != ''">
                <xsl:if test="$currentBetrokkeneIdentificatie/*:inpBsn/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:inpBsn/text()">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:when>
            <xsl:when test="$currentBetrokkeneIdentificatie/*:anpIdentificatie/text() != '' and $matchWithZgwRolBetrokkeneIdentificatie/*:anpIdentificatie/text() != ''">
                <xsl:if test="$currentBetrokkeneIdentificatie/*:anpIdentificatie/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:anpIdentificatie/text()">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:when>
            <!-- The test checks if all of the elements have the same value on both sides as a whole AND checks if atleast 1 of them is not empty.
                OR statements between () is to prevent positively matching on the absence of all elements on both sides. -->
            <xsl:when test="
                ($currentBetrokkeneIdentificatie/*:inpA_nummer/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:inpA_nummer/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:inpA_nummer)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:inpA_nummer)))) and
                ($currentBetrokkeneIdentificatie/*:geslachtsnaam/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:geslachtsnaam/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:geslachtsnaam)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:geslachtsnaam)))) and
                ($currentBetrokkeneIdentificatie/*:voorvoegselGeslachtsnaam/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:voorvoegselGeslachtsnaam/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:voorvoegselGeslachtsnaam)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:voorvoegselGeslachtsnaam)))) and
                ($currentBetrokkeneIdentificatie/*:voorletters/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:voorletters/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:voorletters)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:voorletters)))) and
                ($currentBetrokkeneIdentificatie/*:voornamen/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:voornamen/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:voornamen)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:voornamen)))) and
                ($currentBetrokkeneIdentificatie/*:geslachtsaanduiding/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:geslachtsaanduiding/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:geslachtsaanduiding)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:geslachtsaanduiding)))) and
                ($currentBetrokkeneIdentificatie/*:geboortedatum/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:geboortedatum/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:geboortedatum)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:geboortedatum)))) and
                ($currentBetrokkeneIdentificatie/*:inpA_nummer/text() != '' or
                $currentBetrokkeneIdentificatie/*:geslachtsnaam/text() != '' or 
                $currentBetrokkeneIdentificatie/*:voorvoegselGeslachtsnaam/text() != '' or 
                $currentBetrokkeneIdentificatie/*:voorletters/text() != '' or 
                $currentBetrokkeneIdentificatie/*:voornamen/text() != '' or 
                $currentBetrokkeneIdentificatie/*:geslachtsaanduiding/text() != '' or 
                $currentBetrokkeneIdentificatie/*:geboortedatum/text() != '')
                ">
                <xsl:copy-of select="." />
            </xsl:when>
            <xsl:otherwise />
        </xsl:choose>
    </xsl:template>

    <!-- MDW-kerngegevensKennisgeving -->
    <xsl:template match="*[*:betrokkeneType = 'medewerker' and *:omschrijving = $MatchWithZgwRol/*/*:omschrijving]">
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> betrokkeneIdentificatieTemplateInput: [{serialize(., $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="matchWithZgwRolBetrokkeneIdentificatie" select="$MatchWithZgwRol/*/*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> matchWithZgwRolBetrokkeneIdentificatie: [{serialize($matchWithZgwRolBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="currentBetrokkeneIdentificatie" select="*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> currentBetrokkeneIdentificatie: [{serialize($currentBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:choose>
            <xsl:when test="$currentBetrokkeneIdentificatie/*:identificatie/text() != '' and $matchWithZgwRolBetrokkeneIdentificatie/*:identificatie/text() != ''">
                <xsl:if test="$currentBetrokkeneIdentificatie/*:identificatie/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:identificatie/text()">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:when>
            <!-- The test checks if all of the elements have the same value on both sides as a whole AND checks if atleast 1 of them is not empty.
                OR statements between () is to prevent positively matching on the absence of all elements on both sides. -->
            <xsl:when test="
                ($currentBetrokkeneIdentificatie/*:achternaam/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:achternaam/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:achternaam)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:achternaam)))) and
                ($currentBetrokkeneIdentificatie/*:voorletters/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:voorletters/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:voorletters)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:voorletters)))) and
                ($currentBetrokkeneIdentificatie/*:voorvoegselAchternaam/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:voorvoegselAchternaam/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:voorvoegselAchternaam)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:voorvoegselAchternaam)))) and
                ($currentBetrokkeneIdentificatie/*:achternaam/text() != '' or 
                $currentBetrokkeneIdentificatie/*:voorletters/text() != '' or 
                $currentBetrokkeneIdentificatie/*:voorvoegselAchternaam/text() != '')
                ">
                <xsl:copy-of select="." />
            </xsl:when>
            <xsl:otherwise />
        </xsl:choose>
    </xsl:template>

    <!-- OEH-kerngegevensKennisgeving -->
    <xsl:template match="*[*:betrokkeneType = 'organisatorische_eenheid' and *:omschrijving = $MatchWithZgwRol/*/*:omschrijving]">
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> betrokkeneIdentificatieTemplateInput: [{serialize(., $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="matchWithZgwRolBetrokkeneIdentificatie" select="$MatchWithZgwRol/*/*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> matchWithZgwRolBetrokkeneIdentificatie: [{serialize($matchWithZgwRolBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="currentBetrokkeneIdentificatie" select="*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> currentBetrokkeneIdentificatie: [{serialize($currentBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:choose>
            <xsl:when test="$currentBetrokkeneIdentificatie/*:identificatie/text() != '' and $matchWithZgwRolBetrokkeneIdentificatie/*:identificatie/text() != ''">
                <xsl:if test="$currentBetrokkeneIdentificatie/*:identificatie/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:identificatie/text()">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:when>
            <!-- The test checks if all of the elements have the same value on both sides as a whole AND checks if atleast 1 of them is not empty.
                OR statements between () is to prevent positively matching on the absence of all elements on both sides. -->
            <xsl:when test="
                ($currentBetrokkeneIdentificatie/*:naam/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:naam/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:naam)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:naam)))) and
                ($currentBetrokkeneIdentificatie/*:isGehuisvestIn = $matchWithZgwRolBetrokkeneIdentificatie/*:isGehuisvestIn or 
                (not(exists($currentBetrokkeneIdentificatie/*:isGehuisvestIn)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:isGehuisvestIn)))) and
                ($currentBetrokkeneIdentificatie/*:naam/text() != '' or
                string-length($currentBetrokkeneIdentificatie/*:isGehuisvestIn) gt 0)
                ">
                <xsl:copy-of select="." />
            </xsl:when>
            <xsl:otherwise />
        </xsl:choose>
    </xsl:template>

    <!-- VES-zkn-kerngegevensKennisgeving -->
    <xsl:template match="*[*:betrokkeneType = 'vestiging' and *:omschrijving = $MatchWithZgwRol/*/*:omschrijving]">
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> betrokkeneIdentificatieTemplateInput: [{serialize(., $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="matchWithZgwRolBetrokkeneIdentificatie" select="$MatchWithZgwRol/*/*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> matchWithZgwRolBetrokkeneIdentificatie: [{serialize($matchWithZgwRolBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:variable name="currentBetrokkeneIdentificatie" select="*:betrokkeneIdentificatie" />
        <xsl:if test="$debug = 'true'"><xsl:comment expand-text="yes"> currentBetrokkeneIdentificatie: [{serialize($currentBetrokkeneIdentificatie, $debugSerializeParams)}] </xsl:comment></xsl:if>

        <xsl:choose>
            <xsl:when test="$currentBetrokkeneIdentificatie/*:vestigingsNummer/text() != '' and $matchWithZgwRolBetrokkeneIdentificatie/*:vestigingsNummer/text() != ''">
                <xsl:if test="$currentBetrokkeneIdentificatie/*:vestigingsNummer/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:vestigingsNummer/text()">
                    <xsl:copy-of select="." />
                </xsl:if>
            </xsl:when>
            <!-- The test checks if all of the elements have the same value on both sides as a whole AND checks if atleast 1 of them is not empty.
                OR statements between () is to prevent positively matching on the absence of all elements on both sides. -->
            <xsl:when test="
                ($currentBetrokkeneIdentificatie/*:handelsnaam/text() = $matchWithZgwRolBetrokkeneIdentificatie/*:handelsnaam/text() or 
                (not(exists($currentBetrokkeneIdentificatie/*:handelsnaam)) and not(exists($matchWithZgwRolBetrokkeneIdentificatie/*:handelsnaam)))) and
                $currentBetrokkeneIdentificatie/*:handelsnaam/text() != ''
                ">
                <xsl:copy-of select="." />
            </xsl:when>
            <xsl:otherwise />
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>