class PagesController < ApplicationController
def home
    require 'linkeddata'
    # require 'rdf/ntriples'
    require 'sparql/client'
    require 'sparql'

    # @cultural_properties = CulturalProperty.all
    @statement_1 ||= []
    @statement_2 ||= []
    @statement_3 ||= []
    @statement_4 ||= []
    @statement_5 ||= []
    @statement_6 ||= []
    @statement_7 ||= []
    @statement_8 ||= []
    @statement_9 ||= []
    @statement_10 ||= []
    @statement_11 ||= []
    @statement_12 ||= []
    @geo ||= []


    ## QUERY SPARQL
    sparql = SPARQL::Client.new("https://dati.cultura.gov.it/sparql")

    # https://dati.cultura.gov.it/sparql
    # https://developers.italia.it/it/api/mic-data-sparql
    # https://dati.beniculturali.it/arco-rete-ontologie#esempi

    # @cultural_properties.each do |cultural_property|

    @query_to_run_1 = "
      SELECT (COUNT(?c) AS ?cCount)
      WHERE {
        ?c a-cd:isLocatedIn <https://w3id.org/arco/resource/ArchitecturalOrLandscapeHeritage/0700109690> ;
        dc:subject ?o FILTER(str(?o)='campana')
      }
      "

    @query_to_run_2 = "
      SELECT DISTINCT ?b ?bDesc 
      WHERE {
        ?b a-cd:isLocatedIn<https://w3id.org/arco/resource/ArchitecturalOrLandscapeHeritage/0700109690> ;
        dc:description ?bDesc ;
        dc:subject ?o FILTER(str(?o)='campana')
      }
      "

    @query_to_run_3 = "
      SELECT DISTINCT ?q ?d
      WHERE {
        <https://w3id.org/arco/resource/MusicHeritage/0700377974-0> arco:numberOfComponents ?q ;
        core:description ?d
      }
      "

    @query_to_run_4 = "
      PREFIX clv: <https://w3id.org/italia/onto/CLV/>
      PREFIX cis: <http://dati.beniculturali.it/cis/>
      SELECT DISTINCT ?cLabel ?fullAddress ?cLat ?cLong ?pic
      WHERE {
        <https://w3id.org/arco/resource/MusicHeritage/0700377974-0> a-loc:hasCulturalPropertyAddress ?a ;
        foaf:depiction ?pic ;
        clv:hasGeometry ?g .
        ?g  a-loc:hasCoordinates  ?coord .
        ?coord a-loc:lat ?cLat ;
        a-loc:long ?cLong .
        ?c   cis:siteAddress   ?a ;
        rdfs:label    ?cLabel .
        ?a  clv:fullAddress   ?fullAddress .
      }
      "

    @query_to_run_5 = "
      SELECT ?b ?desc
      WHERE {
        ?b arco:isCulturalPropertyComponentOf <https://w3id.org/arco/resource/MusicHeritage/0700377974-0> ;
        core:description ?desc ;
        dc:subject?o filter(str(?o)='campana')
      }
      "

    @query_to_run_6 = "
      SELECT ?b ?desc ?url
      WHERE {
        ?b arco:isCulturalPropertyComponentOf <https://w3id.org/arco/resource/MusicHeritage/0700377974-0>;
        core:description ?desc ;
        dc:subject?o filter(str(?o)='campana') .
        ?doc a-cd:isDocumentationOf ?b;
        <https://w3id.org/italia/onto/SM/URL> ?url ;
        rdf:type ?docType FILTER(?docType = a-cd:AudioDocumentation) .
      }
      "

    @query_to_run_7 = "
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      SELECT ?b ?desc ?wVal
      WHERE {
        ?b a-cd:isLocatedIn<https://w3id.org/arco/resource/ArchitecturalOrLandscapeHeritage/0700109690> ;
        a-dd:hasMeasurementCollection ?mc ;
        dc:description ?desc ;
        dc:subject ?o FILTER(str(?o)='campana') .
        ?mc a-dd:hasMeasurement ?m  .
        ?m a-dd:hasMeasurementType ?mType FILTER(?mType = a-dd:Weight) .
        ?m a-dd:hasValue ?w .
        ?w <https://w3id.org/italia/onto/MU/value> ?wVal
        } ORDER BY DESC(xsd:integer(?wVal))
      "

    @query_to_run_8 = "
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      SELECT (SUM(xsd:integer(?wVal)) AS ?total)
      WHERE {
        ?b a-cd:isLocatedIn<https://w3id.org/arco/resource/ArchitecturalOrLandscapeHeritage/0700109690> ;
        a-dd:hasMeasurementCollection ?mc ;
        dc:description ?desc ;
        dc:subject ?o FILTER(str(?o)='campana') .
        ?mc a-dd:hasMeasurement ?m  .
        ?m a-dd:hasMeasurementType ?mType FILTER(?mType = a-dd:Weight) .
        ?m a-dd:hasValue ?w .
        ?w <https://w3id.org/italia/onto/MU/value> ?wVal
      }
      "

    @query_to_run_9 = "
      SELECT DISTINCT ?desc ?n ?evType ?startEndEv
      WHERE {
        ?b  arco:isCulturalPropertyComponentOf <https://w3id.org/arco/resource/MusicHeritage/0700377974-0>;
        core:description ?desc ;
        a-cd:hasDating ?cron ;
        a-cd:hasAuthor ?c;
        dc:subject?o filter(str(?o)='campana') .
        ?c l0:name ?n .
        ?cron a-cd:hasDatingEvent ?dEv .
        ?dEv rdfs:label ?evType ;
        a-cd:specificTime ?evDate .
        ?evDate rdfs:label ?startEndEv 
        FILTER langMatches(lang(?evType), 'it')
      }
      "

    @query_to_run_10 = "
        PREFIX clv: <https://w3id.org/italia/onto/CLV/>
        SELECT ?locTypeLabel ?cLat ?cLong
        WHERE {
          ?g clv:isGeometryFor <https://w3id.org/arco/resource/DemoEthnoAnthropologicalHeritage/0700378016-0>.
          ?g a-loc:hasLocationType ?locType ;
          a-loc:hasCoordinates ?c .
          ?c a-loc:lat ?cLat;
          a-loc:long ?cLong .
          ?locType rdfs:label ?locTypeLabel
          FILTER langMatches(lang(?locTypeLabel), 'it')
      }
      "

    @query_to_run_11 = "
      SELECT ?t ?a ?docURL ?pic
      WHERE {
        ?t rdf:type arco:DemoEthnoAnthropologicalHeritage ;
        a-loc:hasCulturalPropertyAddress ?l ;
        foaf:depiction ?pic ;
        dc:subject ?o FILTER regex(str(?o), 'cordette') .
        ?l rdfs:label ?a .
        ?doc a-cd:isDocumentationOf ?t ;
        <https://w3id.org/italia/onto/SM/URL> ?docURL .
      }
      "

    @query_to_run_12 = "
      SELECT ?t ?a ?docURL ?pic
      WHERE {
        ?t rdf:type arco:DemoEthnoAnthropologicalHeritage ;
        a-loc:hasCulturalPropertyAddress ?l ;
        foaf:depiction ?pic ;
        dc:subject ?o FILTER regex(str(?o), 'tastiera') .
        ?l rdfs:label ?a .
        ?doc a-cd:isDocumentationOf ?t ;
        <https://w3id.org/italia/onto/SM/URL> ?docURL .
      }
      "
        # query_to_run_100 = "
        #   PREFIX arco-catalogue: <https://w3id.org/arco/ontology/catalogue/>
        #   PREFIX roapit: <https://w3id.org/italia/onto/RO/>
        #   PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        #   PREFIX clv: <https://w3id.org/italia/onto/CLV/>
        #   SELECT ?lab ?url ?serialization ?dating ?desc ?loc
        #   WHERE{ <" + cultural_property.url + ">
        #     rdfs:label ?lab ;
        #     dc:date ?dating ;
        #     dc:description ?desc ;
        #     a-cd:isLocatedIn ?where ;
        #     a-cd:hasDocumentation ?o ;
        #     clv:hasGeometry ?geom .
        #     ?geom clv:serialization ?serialization .
        #     ?o <https://w3id.org/italia/onto/SM/URL> ?url .
        #     ?where rdfs:label ?loc .

        #   } LIMIT 1"

          query1 = sparql.query(@query_to_run_1)
          query1.each_solution do |statement|
                @statement_1.push(statement)
          end

          query2 = sparql.query(@query_to_run_2)
          query2.each_solution do |statement|
                @statement_2.push(statement)
          end

          query3 = sparql.query(@query_to_run_3)
          query3.each_solution do |statement|
                @statement_3.push(statement)
          end

          query4 = sparql.query(@query_to_run_4)
          query4.each_solution do |statement|
                @statement_4.push(statement)
          end

          query5 = sparql.query(@query_to_run_5)
          query5.each_solution do |statement|
                @statement_5.push(statement)
          end

          query6 = sparql.query(@query_to_run_6)
          query6.each_solution do |statement|
                @statement_6.push(statement)
          end

          query7 = sparql.query(@query_to_run_7)
          query7.each_solution do |statement|
                @statement_7.push(statement)
          end

          query8 = sparql.query(@query_to_run_8)
          query8.each_solution do |statement|
                @statement_8.push(statement)
          end

          query9 = sparql.query(@query_to_run_9)
          query9.each_solution do |statement|
                @statement_9.push(statement)
          end

          query10 = sparql.query(@query_to_run_10)
          query10.each_solution do |statement|
                @statement_10.push(statement)
          end

          query11 = sparql.query(@query_to_run_11)
          query11.each_solution do |statement|
                @statement_11.push(statement)
          end

          query12 = sparql.query(@query_to_run_12)
          query12.each_solution do |statement|
                @statement_12.push(statement)
          end


    # end




  end
end
