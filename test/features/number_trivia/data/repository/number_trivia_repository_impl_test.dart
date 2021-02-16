import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_flutter/core/error/exceptions.dart';
import 'package:tdd_flutter/core/error/failures.dart';
import 'package:tdd_flutter/core/platform/network_info.dart';
import 'package:tdd_flutter/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_flutter/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_flutter/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_flutter/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_flutter/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('Should check if the device in connected', () async {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      //act
      repository.getConcreteNumberTrivia(tNumber);
      //assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestOnline(() {
      test(
          'Should return remote data when the call to remote data source is unsuccessful',
          () async {
        //arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'Should cache the data locally when the call to remote data source is unsuccessful',
          () async {
        //arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'Should return server failure data when the call to remote data source is unsuccessful',
          () async {
        //arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenThrow(ServerException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestOffline( () {

      test('should return locally cached data when the cached data is present',
          () async {
        //arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((realInvocation) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return CacheFailure when there is no data present',
          () async {
        //arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure)));
      });
    });
  });


  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
    NumberTriviaModel(text: 'test trivia', number: 123);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('Should check if the device in connected', () async {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      //act
      repository.getRandomNumberTrivia();
      //assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestOnline(() {
      test(
          'Should return remote data when the call to remote data source is unsuccessful',
              () async {
            //arrange
            when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                .thenAnswer((_) async => tNumberTriviaModel);
            //act
            final result = await repository.getRandomNumberTrivia();
            //assert
            verify(mockRemoteDataSource.getRandomNumberTrivia());
            expect(result, equals(Right(tNumberTrivia)));
          });

      test(
          'Should cache the data locally when the call to remote data source is unsuccessful',
              () async {
            //arrange
            when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                .thenAnswer((_) async => tNumberTriviaModel);
            //act
            await repository.getRandomNumberTrivia();
            //assert
            verify(mockRemoteDataSource.getRandomNumberTrivia());
            verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
          });

      test(
          'Should return server failure data when the call to remote data source is unsuccessful',
              () async {
            //arrange
            when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                .thenThrow(ServerException());
            //act
            final result = await repository.getRandomNumberTrivia();
            //assert
            verify(mockRemoteDataSource.getRandomNumberTrivia());
            verifyZeroInteractions(mockLocalDataSource);
            expect(result, equals(Left(ServerFailure())));
          });
    });

    runTestOffline( () {

      test('should return locally cached data when the cached data is present',
              () async {
            //arrange
            when(mockLocalDataSource.getLastNumberTrivia())
                .thenAnswer((realInvocation) async => tNumberTriviaModel);
            //act
            final result = await repository.getRandomNumberTrivia();
            //assert
            verifyZeroInteractions(mockRemoteDataSource);
            verify(mockLocalDataSource.getLastNumberTrivia());
            expect(result, equals(Right(tNumberTrivia)));
          });

      test('should return CacheFailure when there is no data present',
              () async {
            //arrange
            when(mockLocalDataSource.getLastNumberTrivia())
                .thenThrow(CacheException());
            //act
            final result = await repository.getRandomNumberTrivia();
            //assert
            verifyZeroInteractions(mockRemoteDataSource);
            verify(mockLocalDataSource.getLastNumberTrivia());
            expect(result, equals(Left(CacheFailure)));
          });
    });
  });
}
