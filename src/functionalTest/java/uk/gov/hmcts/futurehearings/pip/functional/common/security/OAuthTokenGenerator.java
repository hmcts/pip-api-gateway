package uk.gov.hmcts.futurehearings.pip.functional.common.security;

import static io.restassured.RestAssured.expect;

import io.restassured.http.ContentType;
import io.restassured.response.Response;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;

@Slf4j
public class OAuthTokenGenerator {

    public static String generateOAuthToken(final String token_apiURL,
                                            final String token_apiTenantId,
                                            final String grantType,
                                            final String clientID,
                                            final String clientSecret,
                                            final String scope,
                                            final HttpStatus httpStatus) {

        String full_token_apiURL = String.format(token_apiURL, token_apiTenantId);
        final String bodyForToken = String.format("grant_type=%s&client_id=%s&client_secret=%s&scope=%s",
                                                  grantType, clientID, clientSecret, scope);

        Response response = callTokenGeneratorEndpoint(bodyForToken, httpStatus, full_token_apiURL);
        return response.jsonPath().getString("access_token");
    }

    public static Response callTokenGeneratorEndpoint(final String bodyForToken,
                                                      final HttpStatus badRequest,
                                                      final String full_token_apiURL) {
        return expect().that().statusCode(badRequest.value())
            .given()
            .body(bodyForToken)
            .contentType(ContentType.URLENC)
            .baseUri(full_token_apiURL)
            .when()
            .post()
            .then()
            .extract()
            .response();
    }
}
